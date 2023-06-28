object DM: TDM
  OnCreate = AndroidServiceCreate
  OnDestroy = AndroidServiceDestroy
  OnStartCommand = AndroidServiceStartCommand
  Height = 357
  Width = 486
  PixelsPerInch = 144
  object IdTCPClient: TIdTCPClient
    ConnectTimeout = 0
    Host = 'daniel-dac-pc'
    Port = 490
    ReadTimeout = -1
    Left = 128
    Top = 64
  end
end
