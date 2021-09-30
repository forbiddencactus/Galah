//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// A simple event class.

public struct Event<T>
{
    private struct Subscriber<S>
    {
        public let subscriber: AnyObject;
        public let callback: (S) -> ();
    }

    private var subscribers = Dictionary<HashableRef<AnyObject>, Subscriber<T>>();
    
    public func Subscribe(_ subscriber: AnyObject, _ callback: @escaping (T) -> ())
    {
        var theSelf = self;
        theSelf.subscribers[subscriber] = Subscriber<T>(subscriber: subscriber, callback: callback);
    }
    
    public func Unsubscribe(_ subscriber: AnyObject)
    {
        var theSelf = self;
        theSelf.subscribers.removeValue(forKey: HashableRef<AnyObject>(subscriber));
    }
    
    public func Broadcast(_ input: T)
    {
        for theSubscriber in subscribers.values
        {
            theSubscriber.callback(input);
        }
    }
}
