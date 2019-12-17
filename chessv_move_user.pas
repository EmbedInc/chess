module chessv_move_user;
define chessv_move_user;
%include 'chessv2.ins.pas';
{
*************************************************************************
*
*   Subroutine CHESSV_MOVE_USER
*
*   Get the next move from the user.
*
*   This routine doesn't actually "get" the move, but sets up the state so
*   that the appropriate event handling routines do get the move.
}
procedure chessv_move_user;            {get the next move from the user}
  val_param;

begin
  if whmove
    then begin                         {white is moving}
      chessv_stat_msg ('chessv_prog', 'stat_move_user_white', nil, 0);
      end
    else begin                         {black is moving}
      chessv_stat_msg ('chessv_prog', 'stat_move_user_black', nil, 0);
      end
    ;

  umove := true;                       {indicate the user is to supply the next move}
  end;
