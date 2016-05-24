{*******************************************************}
{                                                       }
{                    NTS Code Library                   }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit NTS.Code.Environment.PropertyEditors;

interface

{$I '../../Common/CompilerVersion.Inc'}

Uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  System.TypInfo,
  Winapi.Windows,
  Winapi.GDIPAPI,
  Winapi.GDIPOBJ,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtDlgs,
  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  {$ELSE}
  Classes, TypInfo, Windows, Winapi.GDIPAPI, Winapi.GDIPOBJ, Dialogs, Controls, ExtDlgs, Forms, ComCtrls,
  StdCtrls, ExtCtrls, Spin, Graphics,
  {$ENDIF}
  DesignIntf, DesignEditors, ColnEdit;

type
  TFileNameEditor = class(TStringProperty)
  Protected
    function CreateDialog: TOpenDialog; Virtual;
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TImageFileNameEditor = class(TFileNameEditor)
  Protected
    function CreateDialog: TOpenDialog; override;
  end;

  TGPColorDialog = class(TForm)
    pbPreview: TPaintBox;
    seAlpha: TSpinEdit;
    seRed: TSpinEdit;
    seGreen: TSpinEdit;
    seBlue: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    btnEditDialog: TButton;
    btnCancel: TButton;
    btnOk: TButton;
    procedure PreviewPaint(Sender: TObject);
    procedure EditBoxChange(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
  private
    FValue: TGPColor;
    FCanChange: Boolean;
    procedure UpdateControls();
  protected
    procedure DoCreate; override;
  public
    procedure SetValue(AValue: TGPColor);
    class function Execute(var ColorValue: TGPColor): boolean;
  end;

  TGPColorEditor = class(TIntegerProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

implementation

{ TFileNameEditor }

function TFileNameEditor.CreateDialog: TOpenDialog;
begin
  Result:= TOpenDialog.Create(Application);
end;

Procedure TFileNameEditor.Edit;
begin
  with CreateDialog do
  begin
    FileName:= GetValue;
    Options:= Options+[ofPathMustExist, ofFileMustExist];
    try
      if Execute then
        SetValue(FileName);
    finally
      Free;
    end;
  end;
end;

Function TFileNameEditor.GetAttributes: TPropertyAttributes;
begin
  Result:= [paDialog, paRevertable];
end;

{ TImageFileNameEditor }

function TImageFileNameEditor.CreateDialog: TOpenDialog;
begin
  Result:= TOpenPictureDialog.Create(Application);
end;

{ TGPColorDialog }

class function TGPColorDialog.Execute(var ColorValue: TGPColor): boolean;
begin
  with TGPColorDialog.CreateNew(Application) do
  begin
    SetValue(ColorValue);
    Result:= ShowModal = mrOk;
    if Result then
      ColorValue:= FValue;
    Free;
  end;
end;

procedure TGPColorDialog.DoCreate;
begin
  Caption:= 'Edit GP color';
  FCanChange:= True;
  Position:= poMainFormCenter;
  BorderStyle:= bsSingle;
  BorderIcons:= [biSystemMenu];
  ClientWidth:= 400;
  ClientHeight:= 215;
{$REGION 'Controls'}
    pbPreview := TPaintBox.Create(Self);
    seAlpha := TSpinEdit.Create(Self);
    seRed := TSpinEdit.Create(Self);
    seGreen := TSpinEdit.Create(Self);
    seBlue := TSpinEdit.Create(Self);
    Label1 := TLabel.Create(Self);
    Label2 := TLabel.Create(Self);
    Label3 := TLabel.Create(Self);
    Label4 := TLabel.Create(Self);
    Bevel1 := TBevel.Create(Self);
    btnEditDialog := TButton.Create(Self);
    btnCancel := TButton.Create(Self);
    btnOk := TButton.Create(Self);

    with pbPreview do
    begin
      Name := 'pbPreview';
      Parent := Self;
      Left := 175;
      Top := 8;
      Width := 217;
      Height := 149;
      OnPaint:= PreviewPaint;
    end;
    with seAlpha do
    begin
      Name := 'seAlpha';
      Parent := Self;
      Left := 64;
      Top := 8;
      Width := 73;
      Height := 22;
      MaxValue := 255;
      MinValue := 0;
      TabOrder := 0;
      Value := 0;
      OnChange:= EditBoxChange;
    end;
    with seRed do
    begin
      Name := 'seRed';
      Parent := Self;
      Left := 64;
      Top := 48;
      Width := 73;
      Height := 22;
      MaxValue := 255;
      MinValue := 0;
      TabOrder := 1;
      Value := 0;
      OnChange:= EditBoxChange;
    end;
    with seGreen do
    begin
      Name := 'seGreen';
      Parent := Self;
      Left := 64;
      Top := 76;
      Width := 73;
      Height := 22;
      MaxValue := 255;
      MinValue := 0;
      TabOrder := 2;
      Value := 0;
      OnChange:= EditBoxChange;
    end;
    with seBlue do
    begin
      Name := 'seBlue';
      Parent := Self;
      Left := 64;
      Top := 104;
      Width := 73;
      Height := 22;
      MaxValue := 255;
      MinValue := 0;
      TabOrder := 3;
      Value := 0;
      OnChange:= EditBoxChange;
    end;
    with Label1 do
    begin
      Name := 'Label1';
      Parent := Self;
      Left := 27;
      Top := 11;
      Width := 31;
      Height := 13;
      Alignment := taRightJustify;
      Caption := 'Alpha:';
    end;
    with Label2 do
    begin
      Name := 'Label2';
      Parent := Self;
      Left := 35;
      Top := 51;
      Width := 23;
      Height := 13;
      Alignment := taRightJustify;
      Caption := 'Red:';
    end;
    with Label3 do
    begin
      Name := 'Label3';
      Parent := Self;
      Left := 25;
      Top := 79;
      Width := 33;
      Height := 13;
      Alignment := taRightJustify;
      Caption := 'Green:';
    end;
    with Label4 do
    begin
      Name := 'Label4';
      Parent := Self;
      Left := 34;
      Top := 107;
      Width := 24;
      Height := 13;
      Alignment := taRightJustify;
      Caption := 'Blue:';
    end;
    with Bevel1 do
    begin
      Name := 'Bevel1';
      Parent := Self;
      Left := 8;
      Top := 36;
      Width := 161;
      Height := 6;
      Shape := bsBottomLine;
    end;
    with btnEditDialog do
    begin
      Name := 'btnEditDialog';
      Parent := Self;
      Left := 8;
      Top := 132;
      Width := 161;
      Height := 25;
      Caption := 'Color dialog';
      TabOrder := 4;
      OnClick:= btnEditClick;
    end;
    with btnOk do
    begin
      Name := 'btnOk';
      Parent := Self;
      Left := 236;
      Top := 182;
      Width := 75;
      Height := 25;
      Anchors := [akRight, akBottom];
      Caption := 'Ok';
      ModalResult := mrOk;
      TabOrder := 5;
    end;
    with btnCancel do
    begin
      Name := 'btnCancel';
      Parent := Self;
      Left := 317;
      Top := 182;
      Width := 75;
      Height := 25;
      Anchors := [akRight, akBottom];
      Caption := 'Cancel';
      ModalResult := mrCancel;
      TabOrder := 6;
    end;
{$ENDREGION}
  inherited DoCreate;
end;

procedure TGPColorDialog.EditBoxChange(Sender: TObject);
begin
  if FCanChange and (TSpinEdit(Sender).Text <> '') then
  begin
    FValue:= Winapi.GDIPAPI.MakeColor(seAlpha.Value, seRed.Value, seGreen.Value,
      seBlue.Value);
    pbPreview.Invalidate;
  end;
end;

procedure TGPColorDialog.btnEditClick(Sender: TObject);
var
  ColorValue: TColor;
begin
  ColorValue:= {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.RGB( Winapi.GDIPAPI.GetRed(FValue),
    Winapi.GDIPAPI.GetGreen(FValue), Winapi.GDIPAPI.GetBlue(FValue) );
  with TColorDialog.Create(Self) do
  begin
    Color:= ColorValue;
    Options:= [cdFullOpen, cdAnyColor];
    if Execute(Self.Handle) then
    begin
      ColorValue:= Color;
      seRed.Value:= {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.GetRValue(ColorValue);
      seGreen.Value:= {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.GetGValue(ColorValue);
      seBlue.Value:= {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.GetBValue(ColorValue);
      pbPreview.Invalidate;
    end;
  end;
end;

procedure TGPColorDialog.PreviewPaint(Sender: TObject);
var
  Brush: TGPBrush;
  ARect: TGPRect;
  Surface: TGPGraphics;
begin
  pbPreview.Canvas.Brush.Color:= {$IFDEF HAS_UNITSCOPE}Winapi.{$ENDIF}Windows.RGB(Winapi.GDIPAPI.GetRed(FValue),
    Winapi.GDIPAPI.GetGreen(FValue), Winapi.GDIPAPI.GetBlue(FValue) );
  pbPreview.Canvas.FillRect( Rect(0,0,75,75) );

  pbPreview.Canvas.Brush.Color:= clWhite;
  pbPreview.Canvas.FillRect( Rect(100, 0, 120, pbPreview.Height) );

  pbPreview.Canvas.Brush.Color:= clBlack;
  pbPreview.Canvas.FillRect( Rect(150, 0, 170, pbPreview.Height) );

  Surface:= TGPGraphics.Create(pbPreview.Canvas.Handle);
  Brush:= TGPSolidBrush.Create(FValue);
  ARect:= Winapi.GDIPAPI.MakeRect(80, pbPreview.Height-75, pbPreview.Width,
    pbPreview.Height);

  Surface.FillRectangle(Brush,ARect);

  Brush.Free;
  Surface.Free;
end;

procedure TGPColorDialog.SetValue(AValue: TGPColor);
begin
  FValue:= AValue;
  UpdateControls();
end;

procedure TGPColorDialog.UpdateControls;
begin
  FCanChange:= False;
  seAlpha.Value:= Winapi.GDIPAPI.GetAlpha(FValue);
  seRed.Value:= Winapi.GDIPAPI.GetRed(FValue);
  seGreen.Value:= Winapi.GDIPAPI.GetGreen(FValue);
  seBlue.Value:= Winapi.GDIPAPI.GetBlue(FValue);
  FCanChange:= True;
  pbPreview.Invalidate;
end;

{ TGPColorEditor }

procedure TGPColorEditor.Edit;
var
  ColorValue: TGPColor;
begin
  ColorValue:= GetOrdValue;
  if TGPColorDialog.Execute(ColorValue) then
    SetOrdValue(ColorValue);
end;

function TGPColorEditor.GetAttributes: TPropertyAttributes;
begin
  Result:= [paDialog, paRevertable];
end;

end.
