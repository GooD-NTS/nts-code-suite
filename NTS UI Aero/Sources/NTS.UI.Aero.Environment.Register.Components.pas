{*******************************************************}
{                                                       }
{                   NTS Aero UI Library                 }
{         Created by GooD-NTS ( good.nts@gmail.com )    }
{           http://ntscorp.ru/  Copyright(c) 2011       }
{          License: Mozilla Public License 1.1          }
{                                                       }
{*******************************************************}

unit NTS.UI.Aero.Environment.Register.Components;

interface

{$I '../../Common/CompilerVersion.Inc'}

uses
  {$IFDEF HAS_UNITSCOPE}
  System.Classes,
  System.TypInfo,
  {$ELSE}
  Classes, TypInfo,
  {$ENDIF}
  DesignIntf,
  UI.Aero.Window,
  UI.Aero.SearchBox,
  UI.Aero.Button,
  UI.Aero.Button.Task,
  UI.Aero.Labels,
  UI.Aero.PageManager,
  UI.Aero.Image,
  UI.Aero.ThemeElement,
  UI.Aero.Panel,
  UI.Aero.Button.Image,
  UI.Aero.ListBox,
  UI.Aero.ToolTip,
  UI.Aero.Composition,
  UI.Aero.Button.Extended,
  UI.Aero.Button.Image.Extended,
  UI.Aero.Footer,
  UI.Aero.Button.Theme,
  UI.Aero.Button.Expando,
  UI.Aero.ColorHost,
  UI.Aero.BackForward,
  UI.Aero.RecentList,
  UI.Aero.StatusBox,
  UI.Aero.black.GameButton;


  Procedure Register;

Implementation

Procedure Register;
begin
// Aero Standard
  RegisterComponents('Aero Standard'  , [ TAeroWindow ]);
  RegisterComponents('Aero Standard'  , [ TAeroLabel ]);
  //RegisterComponents('Aero Standard'  , [ TAeroEdit ]);
  RegisterComponents('Aero Standard'  , [ TAeroButton ]);
  RegisterComponents('Aero Standard'  , [ TAeroTaskButton ]);
  RegisterComponents('Aero Standard'  , [ TAeroExpandoButton ]);
  RegisterComponents('Aero Standard'  , [ TAeroImage ]);
  RegisterComponents('Aero Standard'  , [ TAeroPanel ]);

// Aero Additional
  RegisterComponents('Aero Additional', [ TAeroPageManager ]);
  RegisterComponents('Aero Additional', [ TAeroThemeElement ]);
  RegisterComponents('Aero Additional', [ TAeroImageButton ]);
  RegisterComponents('Aero Additional', [ TAeroThemeButton ]);
  RegisterComponents('Aero Additional', [ TAeroListBox ]);
  RegisterComponents('Aero Additional', [ TAeroComposition ]);
  RegisterComponents('Aero Additional', [ TAeroAnimationComposition ]);
  RegisterComponents('Aero Additional', [ TAeroToolTip ]);
  RegisterComponents('Aero Additional', [ TAeroSearchBox ]);

// Aero Extented
  RegisterComponents('Aero Extended'  , [ TAeroButtonEx ]);
  RegisterComponents('Aero Extended'  , [ TAeroImageButtonEx ]);
  RegisterComponents('Aero Extended'  , [ TAeroFooter ]);
  //RegisterComponents('Aero Extented'  , [ TAeroStdButton ]);
// Aero Special
  RegisterComponents('Aero Special'   , [ TAeroColorHost ]);
  RegisterComponents('Aero Special'   , [ TAeroBackForward ]);
  RegisterComponents('Aero Special'   , [ TAeroIEBackForward ]);
  RegisterComponents('Aero Special'   , [ TAeroRecentList ]);
  RegisterComponents('Aero Special'   , [ TAeroStatusBox ]);
  RegisterComponents('Aero Special'   , [ TAeroStatusButton ]);
  RegisterComponents('Aero Special'   , [ TBlackGameButton ]);
  RegisterComponents('Aero Special'   , [ TAeroColorButton ]);

{
[Aero Standard]
TAeroWindow
TAeroLabel
TAeroEdit
TAeroButton
TAeroTaskButton
TAeroImage
TAeroPanel

[Aero Additional]
TAeroPageManager
TAeroThemeElement
TAeroImageButton
TAeroListBox
TAeroComposition
TAeroImageComposition
TAeroThemeComposition
TAeroToolTip
TAeroSearchBox

[Aero Extented]
TAeroStdButton
TAeroButtonEx
TAeroImageButtonEx

[Aero Special]
TAeroColorHost

_____
[All]
////////////////
  RegisterComponents('Aero Standard'  , [  ]);
  RegisterComponents('Aero Additional', [  ]);
  RegisterComponents('Aero Extented'  , [  ]);
  RegisterComponents('Aero Special'   , [  ]);

 RegisterComponents('Aero Components', [ TAeroWindow ]);
 RegisterComponents('Aero Components', [ TAeroSearchBox ]);
 RegisterComponents('Aero Components', [ TAeroButton ]);
 RegisterComponents('Aero Components', [ TAeroLabel ]);
 RegisterComponents('Aero Components', [ TAeroImageComposition ]);
 RegisterComponents('Aero Components', [ TAeroPageManager ]);
 RegisterComponents('Aero Components', [ TAeroImage ]);
 RegisterComponents('Aero Components', [ TAeroThemeElement ]);
 RegisterComponents('Aero Components', [ TAeroPanel ]);
 RegisterComponents('Aero Components', [ TAeroImageButton ]);
 RegisterComponents('Aero Components', [ TAeroImageButtonEx ]);
 RegisterComponents('Aero Components', [ TAeroTaskButton ]);
 RegisterComponents('Aero Components', [ TAeroListBox ]);
 RegisterComponents('Aero Components', [ TAeroToolTip ]);

{
 To-DO:
  - Доделать и исправить все компоненты.
  - Удалить не используешеися Uses ссылки.
  - Заменить функцию IsCompositionEnabled на переменную TAeroWindow.CompositionEnabled.
  - Сделать что-то с функциеё AlphaBlend, например DrawAeroImage.
  - Встроить мехаизм пердотвращения загрузки дубликатов в AeroPicture
    (
     0. Список всех загружаеных файлов, посчет кол-ва ссылко на один файл
     1. Создается hash загружаемого файла
     2. При следующих загрузках проверять hash и еслифайл уже загружен давать на него еще одну ссылку
    )
  - Компонент TAeroToolTip
  - Компонент TAeroButtonEx
  - ? Расширить TAeroListBox ?

TAeroTaskButton.AutoSize

TAeroTaskButton.Glow

      
DrawAeroText(DC: hDC;Text: PWideChar;Rect: TRect;Format: DWORD;X,Y: Integer;Theme: hTheme; pOpt: pExtOpt);

 Надо две процедуры DrawAeroText;

pExtOpt = record
  Color: TColor;
  GlowSize: Integer;
end;

}
end;

end.
