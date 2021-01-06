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
  System.SysUtils;
  {$ELSE}
  Classes, SysUtils;
  {$ENDIF}

type
  TVirtualStringList = class(TComponent)
  private
    FLines: TStrings;
    fSetCount: Integer;
    function GetText: String;
    procedure SetText(const Value: String);
    procedure SetNewCount(const Value: Integer);
    procedure SetLines(const Value: TStrings);
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  published
    property SetCount: Integer Read fSetCount Write SetNewCount;
    property Lines: TStrings read FLines write SetLines;
    property Text: String Read GetText Write SetText;
  end;

implementation

{ TVirtualStringList }

Constructor TVirtualStringList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fSetCount:= 0;
  FLines:= TStringList.Create;
end;

Destructor TVirtualStringList.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

function TVirtualStringList.GetText: String;
begin
  Result:= FLines.Text;
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
  FLines.Text:= Value;
end;

end.
