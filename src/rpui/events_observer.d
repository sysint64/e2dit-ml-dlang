module rpui.events_observer;

import rpui.events;
import std.algorithm.mutation;
import std.variant;

interface Subscriber {
    void onEventReceived(in Variant event);
}

final class ListenerSubscriber(T) : Subscriber {
    private void delegate(in T event) listener = null;
    private void delegate() listenerWithoutEvent = null;

    this(void delegate(in T event) listener) {
        this.listener = listener;
    }

    this(void delegate() listener) {
        this.listenerWithoutEvent = listener;
    }

    override void onEventReceived(in Variant event) {
        if (event.type != typeid(const(T)))
            return;

        if (listener !is null) {
            listener(event.get!(const(T)));
        } else {
            listenerWithoutEvent();
        }
    }
}

class EventsSubscriber(T) : Subscriber {
    private T listener;

    this(T listener) {
        this.listener = listener;
    }

    override void onEventReceived(in Variant event) {
        enum events = [
            "KeyPressed",
            "KeyReleased",
            "TextEntered",
            "MouseDown",
            "MouseUp",
            "DblClick",
            "MouseMove",
            "MouseWheel",
            "WindowResize"
        ];
        onEventReceivedFor!(events)(event);
    }

    protected void onEventReceivedFor(string[] events)(in Variant event) {
        static foreach (eventName; events) {
            {
                mixin("alias eventType = " ~ eventName ~ "Event;");

                if (event.type == typeid(const(eventType))) {
                    const e = event.get!(const(eventType));
                    mixin("listener.on" ~ eventName ~ "(e);");
                }
            }
        }
    }
}

class EventsObserver {
    private bool[EventsObserver] observerIsActive;
    private EventsObserver[] joinedObservers;
    private Subscriber[] subscribers;

    bool subscriberIsNotifiable(Subscriber subscriber) {
        return true;
    }

final:
    Subscriber subscribe(Subscriber subscriber) {
        subscribers ~= subscriber;
        return subscriber;
    }

    Subscriber subscribe(T)(void delegate(in T event) listener) {
        return subscribe(new ListenerSubscriber!(T)(listener));
    }

    Subscriber subscribe(T)(void delegate() listener) {
        return subscribe(new ListenerSubscriber!(T)(listener));
    }

    Subscriber subscribe(EventsListener subscriber) {
        return subscribe(new EventsSubscriber!(EventsListener)(subscriber));
    }

    void unsubscribe(Subscriber subscriber) {
        subscribers = subscribers.remove!(a => a == subscriber);
    }

    void notify(T)(in T event) {
        foreach (subscriber; subscribers) {
            if (subscriberIsNotifiable(subscriber))
                subscriber.onEventReceived(Variant(event));
        }

        foreach (observer; joinedObservers) {
            if (observerIsActive[observer])
                observer.notify(event);
        }
    }

    void join(EventsObserver observer) {
        joinedObservers ~= observer;
        observerIsActive[observer] = true;
    }

    void unjoin(EventsObserver observer) {
        // debug assert(observer in joinedObservers);
        observerIsActive.remove(observer);
        joinedObservers = joinedObservers.remove!(a => a == observer);
    }

    void silent(EventsObserver observer) {
        // debug assert(observer in joinedObservers);
        observerIsActive[observer] = false;
    }

    void unsilent(EventsObserver observer) {
        // debug assert(observer in joinedObservers);
        observerIsActive[observer] = true;
    }
}