program Project1;

 uses
   Classes, Process, SysUtils, lazutf8;


type
  TStringArray = array of string;




function SplitS(S: String; Delimiter:TSysCharSet = [#9]): TStringArray;
 var
    len, idx1, idx2, idx: integer;
 begin
      Result := nil;
      if Length(S) = 0 then Exit;
      len := Length(S);
      SetLength(Result, len);
      idx2 := 1;
      idx := 0;
      repeat
        idx1 := idx2;
        while (idx2 <= len) and not(S[idx2] in Delimiter) do inc(idx2);
        if idx1 <= idx2 then
        begin
           Result[idx] := (Copy(S, idx1, idx2-idx1));
           inc(idx);
        end;
        if (idx2 <= len) and (S[idx2] in Delimiter) then inc(idx2);
      until idx2 > len;
      SetLength(Result, idx);
 end;



var
   hProcess     : TProcess;
   OutputStr: string;
   BytesAvail: DWord;
   PrevLen,ix: integer;

   cd: array of string;
   f, out: text;
   str,fname,outname,linex: string;

begin
  //write('.');
  //Sleep(1000);
  //write('.');
  //Sleep(1000);
  //writeln('.');
  //Sleep(1000);


  fname:='run.cmd';
  outname:='log.txt';

  if (FileExists(fname)) then begin
    assign(f, fname);
    reset(f);

    assign(out, outname);
    rewrite(out);
    close(out);

    while not eof(f) do begin



      readln(f, str);
      writeln('>> ',str);
      writeln('-----------------------------------');


      append(out);
      writeln(out, '>> ' + str);
      writeln(out, '-----------------------------------');
      close(out);



      cd := SplitS(str, [' ']);

      //writeln(cd[0]);

      OutputStr:='';
      hProcess := TProcess.Create(nil);
      hProcess.Executable := cd[0];

      for ix := 1 to length(cd)-1 do begin
        hProcess.Parameters.Add(cd[ix]);
        writeln('['+cd[ix]+']');
        //readln();
      end;

      hProcess.Options := [poUsePipes];//[poUsePipes]; // cannot use poWaitOnExit here

      try  begin
        hProcess.Execute;
        OutputStr := '';
        while hProcess.Running do begin
          BytesAvail := hProcess.Output.NumBytesAvailable;
          if BytesAvail > 0 then begin
            PrevLen := Length(OutputStr);
            SetLength(OutputStr,PrevLen + BytesAvail);
            hProcess.Output.Read(OutputStr[PrevLen + 1],BytesAvail);

            linex := ConsoleToUtf8(OutputStr);
            writeln('>'+linex);

            append(out);
            writeln(out, linex);
            close(out);

          end else begin
            Sleep(1);
          end;
        end;
      end except
         writeln('____');
      end;

      // read last part
      //BytesAvail := hProcess.Output.NumBytesAvailable;
      //if BytesAvail > 0 then begin
      //PrevLen := Length(OutputStr);
      //SetLength(OutputStr,PrevLen + BytesAvail);
      //hProcess.Output.Read(OutputStr[PrevLen + 1],BytesAvail);
      //end;
    end;

    close(f);

  end else begin
      writeln('create file run.cmd');
      readln();
  end;

end.

