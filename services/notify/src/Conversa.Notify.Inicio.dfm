object ConversaNotifyServiceModule: TConversaNotifyServiceModule
  OnCreate = AndroidServiceCreate
  OnDestroy = AndroidServiceDestroy
  OnBind = AndroidServiceBind
  OnUnBind = AndroidServiceUnBind
  OnRebind = AndroidServiceRebind
  OnTaskRemoved = AndroidServiceTaskRemoved
  OnTrimMemory = AndroidServiceTrimMemory
  OnStartCommand = AndroidServiceStartCommand
  Height = 357
  Width = 486
  PixelsPerInch = 144
  object NotificationCenter: TNotificationCenter
    Left = 48
    Top = 12
  end
  object IdUDPClient1: TIdUDPClient
    BroadcastEnabled = True
    Host = '10.0.5.65'
    Port = 49000
    Left = 240
    Top = 93
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    Host = '10.0.5.65'
    Port = 490
    ReadTimeout = -1
    Left = 240
    Top = 21
  end
end
