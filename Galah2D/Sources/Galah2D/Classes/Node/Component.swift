/*
Copyright © 2020 Alexis Griffin.

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
//  Created by Alex Griffin on 13/5/20.
//

public protocol ComponentProtocol: AnyObject
{
    //Basic stuff
    func Construct();
    func Begin();
    //func Tick();
    
    //Enable disable
    func OnEnable(willEnable: Bool);
}

public extension ComponentProtocol
{
    func Construct() {}
    func Begin() {}
    func Tick() {}
    func OnEnable(willEnable: Bool) {}
}

open class _Component: BufferElement
{
    private var _node: Node? = nil;
    public var Node: Node
    {
        get
        {
            return _node!;
        }
    }
    
    internal func Create(_ node: Node)
    {
        _node = node;
        
        guard let this = self as? ComponentProtocol else {
            return
        }
        
        this.Construct();
    }
            
    public var IsTicking: Bool
    {
        get
        {
            return false; //TODO: IMPLEMENT!
        }
    }
}

public typealias Component = _Component & ComponentProtocol;

