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
// A task is a wrapper for a closure.

import GalahNative.Thread;

internal protocol Task
{
    func RunTask()
}

public struct DataTask<DataType>: Task
{
    public typealias TaskClosure = (DataType) -> ();
    public let Closure: TaskClosure;
    public let Data: DataType;
    
    init(_ closure: @escaping TaskClosure, data: DataType)
    {
        self.Closure = closure;
        self.Data = data;
    }
    
    internal func RunTask()
    {
        Closure(Data);
    }
}

public struct UnsafeTask: Task
{
    internal var internalTask: GTask;
    
    internal func RunTask()
    {
        var internalTaskCopyCuzSwiftHasControlIssues = internalTask;
        internalTask.task(&internalTaskCopyCuzSwiftHasControlIssues.taskDataExistentialContainer);
    }
    
    init(withTask: Task)
    {
        let taskType: Any.Type = type(of:withTask);

        if (taskType == UnsafeTask.self)
        {
            let task = withTask as! UnsafeTask;
            self.internalTask = task.internalTask;
        }
        else
        {
            self.internalTask = GTask(task: DataTaskEntryPoint, taskDataExistentialContainer:
                                        (
                                            nil,
                                            nil, // Gawd typing in Swift is horrible...
                                            nil,
                                            nil,
                                            nil
                                        ));
            let ptr: VoidPtr = unsafeBitCast(withTask, to: VoidPtr.self)
            galah_copyValue(dest: &self.internalTask.taskDataExistentialContainer, source: ptr, type: taskType);
        }
    }
}

fileprivate func DataTaskEntryPoint(_ arg: VoidPtr?)
{
    
}
