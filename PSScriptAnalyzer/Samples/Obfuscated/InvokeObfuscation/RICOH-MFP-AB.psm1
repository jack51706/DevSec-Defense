#============================================================================================================================#
#                                                                                                                            #
#  RICOH-MFP-AB.psm1                                                                                                         #
#  Ricoh Multi Function Printer (MFP) Address Book PowerShell Module                                                         #
#  Author: Alexander Krause                                                                                                  #
#  Creation Date: 10.04.2013                                                                                                 #
#  Modified Date: 17.04.2013                                                                                                 #
#  Version: 0.7.7                                                                                                            #
#                                                                                                                            #
#============================================================================================================================#

function ConvertTo-Base64
{
param($String)
[System.Convert]::"tOB`A`Se64`ST`RiNG"([System.Text.Encoding]::"uT`F8".('GetByte'+'s').Invoke($String))
}

function Connect-MFP
{
param($Hostname,$Authentication,$Username,$Password,$SecurePassword)
$url = "http://$Hostname/DH/udirectory"
$login = [xml]@'
<?xml version="1.0" encoding="utf-8" ?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
  <m:startSession xmlns:m="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory">
   <stringIn></stringIn>
   <timeLimit>30</timeLimit>
   <lockMode>X</lockMode>
  </m:startSession>
 </s:Body>
</s:Envelope>
'@
if($SecurePassword -eq $NULL){$pass = ConvertTo-Base64 $Password}else{$pass = $SecurePassword; $enc = "gwpwes003"}
$login."eNvel`OPE"."B`oDY"."St`ARTSe`sS`IOn"."S`TRinG`IN" = "SCHEME="+(ConvertTo-Base64 $Authentication)+";UID:UserName="+(ConvertTo-Base64 $Username)+";PWD:Password=$pass;PES:Encoding=$enc"
[xml]$xml = iwr $url -Method Post -ContentType "text/xml" -Headers @{('S'+'OAP'+'Action')="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory#startSession"} -Body $login
if($xml."e`NvElO`PE"."B`Ody"."S`Tar`TSEs`sio`Nre`SPonSE"."ReTu`R`N`ValUE" -eq "OK"){$script:session = $xml."e`NvE`lOPe"."bO`dy"."s`TAr`TseS`sIO`N`ReSPonSE"."StrI`Ng`oUt"}
}

function Search-MFPAB
{
param($Hostname)
$url = "http://$Hostname/DH/udirectory"
$search = [xml]@'
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
  <m:searchObjects xmlns:m="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory">
    <sessionId></sessionId>
   <selectProps xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.w3.org/2001/XMLSchema" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" soap-enc:arrayType="itt:string[1]">
    <item>id</item>
   </selectProps>
    <fromClass>entry</fromClass>
    <parentObjectId></parentObjectId>
    <resultSetId></resultSetId>
   <whereAnd xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/udirectory" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/udirectory" soap-enc:arrayType="itt:queryTerm[1]">
    <item>
     <operator></operator>
     <propName>all</propName>
     <propVal></propVal>
     <propVal2></propVal2>
    </item>
   </whereAnd>
   <whereOr xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/udirectory" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/udirectory" soap-enc:arrayType="itt:queryTerm[1]">
    <item>
     <operator></operator>
     <propName></propName>
     <propVal></propVal>
     <propVal2></propVal2>
    </item>
   </whereOr>
   <orderBy xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/udirectory" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/udirectory" soap-enc:arrayType="itt:queryOrderBy[1]">
    <item>
     <propName></propName>
     <isDescending>false</isDescending>
    </item>
   </orderBy>
    <rowOffset>0</rowOffset>
    <rowCount>50</rowCount>
    <lastObjectId></lastObjectId>
   <queryOptions xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" soap-enc:arrayType="itt:property[1]">
    <item>
     <propName></propName>
     <propVal></propVal>
    </item>
   </queryOptions>
  </m:searchObjects>
 </s:Body>
</s:Envelope>
'@
$search."eNve`lo`Pe"."bO`dy"."sEA`R`c`hOBJects"."S`ES`sioNiD" = $script:session
[xml]$xml = iwr $url -Method Post -ContentType "text/xml" -Headers @{('SOAPAc'+'t'+'ion')="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory#searchObjects"} -Body $search
$xml.('Sele'+'c'+'tNod'+'es').Invoke("//rowList/item") | %{$_."I`TEm"."p`ROpvAL"} | ?{$_."lE`NGtH" -lt "10"} | %{[int]$_} | sort
}

function Get-MFPAB
{
param($Hostname,$Authentication="BASIC",$Username="admin",$Password,$SecurePassword)
Connect-MFP $Hostname $Authentication $Username $Password $SecurePassword
$url = "http://$Hostname/DH/udirectory"
$get = [xml]@'
<?xml version="1.0" encoding="utf-8" ?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
  <m:getObjectsProps xmlns:m="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory">
   <sessionId></sessionId>
  <objectIdList xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.w3.org/2001/XMLSchema" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="">
  </objectIdList>
  <selectProps xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.w3.org/2001/XMLSchema" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="itt:string[7]">
   <item>entryType</item>
   <item>id</item>
   <item>index</item>
   <item>name</item>
   <item>longName</item>
   <item>auth:name</item>
   <item>mail:address</item>
  </selectProps>
   <options xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="itt:property[1]">
    <item>
     <propName></propName>
     <propVal></propVal>
    </item>
   </options>
  </m:getObjectsProps>
 </s:Body>
</s:Envelope>
'@
$get."e`NVELope"."B`OdY"."geTO`B`J`ecTS`ProPs"."S`eSSiO`NiD" = $script:session
Search-MFPAB $Hostname | %{
$x = $get.('Cre'+'ateE'+'lemen'+'t').Invoke("item")
$x.('s'+'et_In'+'nerT'+'ext').Invoke("entry:$_")
$o = $get."e`NvElo`pe"."B`ODY"."ge`T`ObjEc`TS`PROpS"."obJ`ecTIdLI`St".('A'+'ppend'+'Chi'+'ld').Invoke($x)
}
$get."eNVe`lOpe"."bO`Dy"."Ge`TOBJ`eCTS`P`ROPS"."obj`e`CtiDlI`sT"."arR`AYT`ypE" = "itt:string["+$get."en`V`eLope"."Bo`dY"."GetO`Bject`SprO`ps"."oB`jEc`TidLI`St"."i`Tem"."cO`UNt"+"]"
[xml]$xml = iwr $url -Method Post -ContentType "text/xml" -Headers @{('SOA'+'P'+'A'+'ction')="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory#getObjectsProps"} -Body $get
$xml.('Sel'+'ectNod'+'e'+'s').Invoke("//returnValue/item") | %{
New-Object PSObject -Property @{
   ('En'+'try'+'Type') = (%{$_."i`TEM"} | ?{$_."proP`Na`Me" -eq "entryType"})."Pr`OpVAL"
   ('ID')        = [int](%{$_."It`Em"} | ?{$_."pROpN`A`ME" -eq "id"})."P`ROpVaL"
   ('I'+'ndex')     = [int](%{$_."It`EM"} | ?{$_."ProPn`AME" -eq "index"})."P`ROPV`AL"
   ('Na'+'me')      = (%{$_."i`TEM"} | ?{$_."PRoPN`A`mE" -eq "name"})."PRop`VaL"
   ('Lo'+'ngNam'+'e')  = (%{$_."IT`EM"} | ?{$_."Pro`PnA`ME" -eq "longname"})."prO`P`VAl"
   ('User'+'C'+'ode')  = (%{$_."I`TEm"} | ?{$_."Pr`o`PnamE" -eq "auth:name"})."proPV`AL"
   ('Mai'+'l')      = (%{$_."I`Tem"} | ?{$_."p`ROPnA`me" -eq "mail:address"})."p`Ro`pvAL"
}} | sort Index | ft -a
Disconnect-MFP $Hostname
}

function Add-MFPAB
{
param($Hostname,$Authentication="BASIC",$Username="admin",$Password,$SecurePassword,$EntryType="user",$Index,$Name,$LongName,$UserCode,$Destination="true",$Sender="false",$Mail="true",$MailAddress)
Connect-MFP $Hostname $Authentication $Username $Password $SecurePassword
$url = "http://$Hostname/DH/udirectory"
$add = [xml]@'
<?xml version="1.0" encoding="utf-8" ?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
  <m:putObjects xmlns:m="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory">
   <sessionId></sessionId>
   <objectClass>entry</objectClass>
   <parentObjectId></parentObjectId>
   <propListList xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="">
    <item xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="itt:property[7]">
     <item>
      <propName>entryType</propName>
      <propVal></propVal>
     </item>
     <item>
      <propName>name</propName>
      <propVal></propVal>
     </item>
     <item>
      <propName>longName</propName>
      <propVal></propVal>
     </item>
     <item>
      <propName>isDestination</propName>
      <propVal></propVal>
     </item>
     <item>
      <propName>isSender</propName>
      <propVal></propVal>
     </item>
     <item>
      <propName>mail:</propName>
      <propVal></propVal>
     </item>
     <item>
      <propName>mail:address</propName>
      <propVal></propVal>
     </item>
    </item>
   </propListList>
  </m:putObjects>
 </s:Body>
</s:Envelope>
'@
$add."EnVElO`PE"."bO`Dy"."PU`T`oBJects"."SEss`Io`Nid" = $script:session
$add."E`Nv`elOpe"."b`oDY"."pUt`o`BjeCTs"."Pr`oPLIs`TLiST"."i`TeM"."I`TEm"[0]."P`RoPval" = $EntryType
if($Index -ne $NULL){
$a = $add.('C'+'r'+'ea'+'teEl'+'ement').Invoke("item")
$a.('se'+'t_I'+'n'+'nerText').Invoke("")
$b = $add.('Cr'+'e'+'ateE'+'lem'+'ent').Invoke("propName")
$b.('set_In'+'n'+'e'+'rText').Invoke("index")
$o = $a.('Appe'+'n'+'dCh'+'ild').Invoke($b)
$c = $add.('CreateE'+'lem'+'ent').Invoke("propVal")
$c.('set_In'+'ner'+'Text').Invoke($Index)
$o = $a.('Appe'+'nd'+'Child').Invoke($c)
$o = $add."e`Nv`EloPe"."B`oDy"."P`UtObJE`cts"."P`R`OPl`istLiSt"."iT`em".('Append'+'Chi'+'l'+'d').Invoke($a)
}
$add."EN`V`EloPe"."bo`dY"."puT`Ob`j`ECtS"."prOPLIstL`I`st"."iT`Em"."i`TeM"[1]."PRoPV`AL" = $Name
$add."E`NvEL`oPE"."B`ODY"."pU`Tob`jeCTs"."Pr`O`PliStLIST"."It`Em"."i`TeM"[2]."P`Ro`PVal" = $LongName
if($UserCode -ne $NULL){
$a = $add.('Cr'+'eateEle'+'m'+'ent').Invoke("item")
$a.('set'+'_Inner'+'Text').Invoke("")
$b = $add.('Crea'+'teElem'+'en'+'t').Invoke("propName")
$b.('s'+'et_I'+'nne'+'rT'+'ext').Invoke("auth:name")
$o = $a.('A'+'ppen'+'dChil'+'d').Invoke($b)
$c = $add.('CreateE'+'le'+'ment').Invoke("propVal")
$c.('se'+'t'+'_I'+'nnerText').Invoke($UserCode)
$o = $a.('Append'+'C'+'hil'+'d').Invoke($c)
$o = $add."eN`VEL`opE"."b`ODY"."pUToBjE`c`TS"."p`ROPLiST`LiST"."i`TEm".('Appen'+'dC'+'hil'+'d').Invoke($a)
}
$add."E`NvEl`opE"."bO`DY"."Pu`TObjE`CTs"."pr`op`liSTL`ISt"."i`TeM"."I`TEM"[3]."pR`opVAl" = $Destination
$add."enveL`O`PE"."BO`DY"."puTO`Bjec`TS"."PR`oPLiS`TLI`st"."i`Tem"."i`TEM"[4]."P`Rop`Val" = $Sender
$add."eN`VE`LoPe"."b`ODy"."pU`T`ObJECtS"."pROp`liS`Tl`iST"."it`em"."I`Tem"[5]."p`Ro`pval" = $Mail
$add."EnVe`Lo`pe"."Bo`DY"."PUT`obJE`CtS"."PRO`p`lIStlI`St"."i`Tem"."I`TEM"[6]."PrO`p`VAl" = $MailAddress
$add."e`NVeLo`pE"."Bo`dy"."puT`oBJ`eC`TS"."P`Ropl`iStL`iSt"."aR`RAYty`Pe" = "itt:string[]["+$add."ENV`elo`pe"."BO`dy"."p`UtObje`cTs"."PRo`PLI`St`LiSt"."I`TEm"."i`Tem"."CoU`NT"+"]"
[xml]$xml = iwr $url -Method Post -ContentType "text/xml" -Headers @{('SO'+'APActi'+'on')="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory#putObjects"} -Body $add
Disconnect-MFP $Hostname
}

function Remove-MFPAB
{
param($Hostname,$Authentication="BASIC",$Username="admin",$Password,$SecurePassword,$ID)
Connect-MFP $Hostname $Authentication $Username $Password $SecurePassword
$url = "http://$Hostname/DH/udirectory"
$remove = [xml]@'
<?xml version="1.0" encoding="utf-8" ?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
 <s:Body>
  <m:deleteObjects xmlns:m="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory">
   <sessionId></sessionId>
  <objectIdList xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.w3.org/2001/XMLSchema" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="">
  </objectIdList>
   <options xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:itt="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:type="soap-enc:Array" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:t="http://www.ricoh.co.jp/xmlns/schema/rdh/commontypes" xsi:arrayType="itt:property[1]">
    <item>
     <propName></propName>
     <propVal></propVal>
    </item>
   </options>
  </m:deleteObjects>
 </s:Body>
</s:Envelope>
'@
$remove."EN`VELoPe"."bO`DY"."DEle`TeOb`J`ectS"."Ses`sIO`Nid" = $script:session
$ID | %{
$x = $remove.('C'+'reateElem'+'e'+'nt').Invoke("item")
$x.('set_Inn'+'erT'+'ex'+'t').Invoke("entry:$_")
$o = $remove."env`el`OpE"."Bo`dy"."D`eLEteo`BJ`e`cTs"."ObjE`cTi`dli`st".('Ap'+'pendChi'+'l'+'d').Invoke($x)
}
$remove."E`NV`ElOpE"."bo`dY"."deLeTEO`Bj`ECTs"."obJ`EcTi`dL`iSt"."a`RrA`YTyPe" = "itt:string["+$remove."e`N`VelopE"."Bo`DY"."DeLE`Teo`B`JecTS"."oBJe`ctI`dList"."It`EM"."c`oUnt"+"]"
[xml]$xml = iwr $url -Method Post -ContentType "text/xml" -Headers @{('S'+'OAPAct'+'ion')="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory#deleteObjects"} -Body $remove
Disconnect-MFP $Hostname
}

function Disconnect-MFP
{
param($Hostname)
$url = "http://$Hostname/DH/udirectory"
$logout = [xml]@'
<?xml version="1.0" encoding="utf-8" ?>
 <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
   <m:terminateSession xmlns:m="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory">
    <sessionId></sessionId>
   </m:terminateSession>
  </s:Body>
 </s:Envelope>
'@
$logout."eN`VElOPE"."B`ody"."T`ERm`InA`T`eSEssIon"."SEssi`on`iD" = $script:session
[xml]$xml = iwr $url -Method Post -ContentType "text/xml" -Headers @{('SO'+'APActi'+'on')="http://www.ricoh.co.jp/xmlns/soap/rdh/udirectory#terminateSession"} -Body $logout
}

Export-ModuleMember Get-MFPAB,Add-MFPAB,Remove-MFPAB
