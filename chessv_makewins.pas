module chessv_makewins;
define chessv_makewins;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESSV_MAKEWINS
*
*   Create or re-create the basic set of GUI windows.
}
procedure chessv_makewins;             {create our basic set of GUI windows}

begin
  if windows then begin                {GUI windows currently exist ?}
    gui_win_delete (win_root);         {delete all our GUI windows}
    windows := false;                  {indicate windows don't currently exist}
    end;

  chessv_win_root_init;                {create root window and its contents}
  windows := true;                     {base GUI windows now exist}
  end;
