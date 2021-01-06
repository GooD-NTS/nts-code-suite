{*******************************************************}
{                                                       }
{                    NTS Code Library                   }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit NTS.Code.Components.VirtualStringList;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections;
  {$ELSE}
  Classes, SysUtils;
  {$ENDIF}

type
  TVirtualStringList = class(TComponent)
  private
    FLines: TStrings;
    fSetCount: Integer;
    FDictionary: TDictionary<string,string>;

    function GetText(): String;
    procedure SetText(const Value: String);
    procedure SetNewCount(const Value: Integer);
    procedure SetLines(const Value: TStrings);
    procedure SetDictionary(const Value: TDictionary<string,string>);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    function GetString(Index: Integer): string; overload; inline;
    function GetString(const key: string): string; overload; inline;
  published
    property SetCount: Integer Read fSetCount Write SetNewCount;
    property Lines: TStrings read FLines write SetLines;
    property Text: String Read GetText Write SetText;
    property Dictionary: TDictionary<string,string> read FDictionary write SetDictionary;
  end;

implementation

{ TVirtualStringList }

constructor TVirtualStringList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fSetCount:= 0;
  FLines := TStringList.Create;
  FDictionary := TDictionary<string,string>.Create();
end;

destructor TVirtualStringList.Destroy();
begin
  FDictionary.Free();
  FLines.Free();

  inherited Destroy();
end;

function TVirtualStringList.GetString(Index: Integer): string;
begin
  if (FLines.Count > 0) and (Index > -1) and (Index < FLines.Count - 1) then
    Result:= FLines[Index]
  else
    Result:= 'GetString@' + IntToStr(Index);
end;

function TVirtualStringList.GetString(const key: string): string;
begin
  if not FDictionary.TryGetValue(key, Result) then
    Result := key;
end;

function TVirtualStringList.GetText(): String;
begin
  Result := FLines.Text;
end;

procedure TVirtualStringList.SetDictionary(const Value: TDictionary<string,string>);
begin
  FDictionary.Free();

  FDictionary := TDictionary<string,string>.Create(Value);
end;

Procedure TVirtualStringList.SetLines(const Value: TStrings);
begin
  FLines.Assign(Value);
end;

procedure TVirtualStringList.SetNewCount(const value: Integer);
var
  i: Integer;
begin
  fSetCount := value;
  if not (csDesigning in ComponentState) then
  begin
    if FLines.Count <> value then
    begin
      FLines.Clear();
      for i := 0 to value do
        FLines.Add(IntToStr(i));
    end;
  end;
end;

procedure TVirtualStringList.SetText(const Value: String);
begin
  FLines.Text := Value;
end;

end.
