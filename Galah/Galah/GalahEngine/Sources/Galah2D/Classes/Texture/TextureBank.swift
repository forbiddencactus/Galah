//
//  TextureBank.swift
//  
//
//  Created by Alex Griffin on 14/1/20.
//

public class TextureBank
{
    private var _delegate: TextureBankDelegate! = nil;
    public var Delegate: TextureBankDelegate { get { return _delegate; } set {self.SetTextureBankDelegate(newValue); } }
    
    private var _internalTextureBank: Array<Texture> = Array<Texture>();
    
    private static var _instance: TextureBank! = nil;
    public static var Instance: TextureBank
    {
        get
        {
            if (_instance == nil)
            {
                _instance = TextureBank();
            }
            
            return _instance;
        }
    }
    
    private init()
    {
        
    }
    
    private func SetTextureBankDelegate(_ delegate: TextureBankDelegate)
    {
        _delegate = delegate;
    }
}
