{*******************************************************}
{                                                       }
{                    NTS Code Library                   }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit NTS.Code.Helpers;

interface

{$I '../../Common/CompilerVersion.Inc'}

Uses
  {$IFDEF HAS_UNITSCOPE}
  System.SysUtils, System.Classes, System.Math, Winapi.Windows;
  {$ELSE}
  SysUtils, Windows, Classes, Math;
  {$ENDIF}

type
  TPointHelper = record helper for TPoint
    function InRect(ARect: TRect): BooLean; InLine;
    function ToString: String;
    Procedure FromString(AX,AY: String);
  end;

  TSizeHelper = record helper for TSize
    procedure Make(Width,Height: Integer); InLine;
    function IsValue(Value: Integer): BooLean;  InLine;
  End;

implementation

{ TPointHelper }

procedure TPointHelper.FromString(AX, AY: String);
begin
  Self.X:= StrToInt(AX);
  Self.Y:= StrToInt(AY);
end;

function TPointHelper.InRect(ARect: TRect): BooLean;
begin
  Result:= {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.PtInRect(ARect,Self);
end;

function TPointHelper.ToString: String;
begin
  Result:= IntToStr(Self.X)+','+IntToStr(Self.Y);
end;

{ TSizeHelper }

function TSizeHelper.IsValue(Value: Integer): BooLean;
begin
  Result:= (cx = Value) and (cy = Value);
end;

procedure TSizeHelper.Make(Width, Height: Integer);
begin
  cx:= Width;
  cy:= Height;
end;

end.
