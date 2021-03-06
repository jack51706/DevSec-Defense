

${TyPE`_`Ntfs1} = @' 
	using System;
	using System.IO;
	using System.Collections;
	using System.Runtime.InteropServices;
	using Microsoft.Win32.SafeHandles;
	
	namespace NTFS
	{
		public class DriveInfoExt
		{
			[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
			static extern bool GetDiskFreeSpace(string lpRootPathName,
				out uint lpSectorsPerCluster,
				out uint lpBytesPerSector,
				out uint lpNumberOfFreeClusters,
				out uint lpTotalNumberOfClusters);
	
			DriveInfo _drive = null;
			uint _sectorsPerCluster = 0;
			uint _bytesPerSector = 0;
			uint _numberOfFreeClusters = 0;
			uint _totalNumberOfClusters = 0;
	
			public uint SectorsPerCluster { get { return _sectorsPerCluster; } }
			public uint BytesPerSector { get { return _bytesPerSector; } }
			public uint NumberOfFreeClusters { get { return _numberOfFreeClusters; } }
			public uint TotalNumberOfClusters { get { return _totalNumberOfClusters; } }
			public DriveInfo Drive { get { return _drive; } }
			public string DriveName { get { return _drive.Name; } }
			public string VolumeName { get { return _drive.VolumeLabel; } }
	
			public DriveInfoExt(string DriveName)
			{
				_drive = new DriveInfo(DriveName);
	
				GetDiskFreeSpace(_drive.Name,
					out _sectorsPerCluster,
					out _bytesPerSector,
					out _numberOfFreeClusters,
					out _totalNumberOfClusters);
			}
		}
			
		public class FileInfoExt
		{
			[DllImport("kernel32.dll", SetLastError = true, EntryPoint = "GetCompressedFileSize")]
			static extern uint GetCompressedFileSize(string lpFileName, out uint lpFileSizeHigh);
	
			public static ulong GetCompressedFileSize(string filename)
			{
				uint high;
				uint low;
				low = GetCompressedFileSize(filename, out high);
				int error = Marshal.GetLastWin32Error();
	
				if (high == 0 && low == 0xFFFFFFFF && error != 0)
				{
					throw new System.ComponentModel.Win32Exception(error);
				}
				else
				{
					return ((ulong)high << 32) + low;
				}
			}
		}
	}
'@


function T`e`sting`-addorPH`A`N`E`DacES([string] ${PA`Th})
{
	if (-not (.("{2}{1}{0}"-f'ath','est-P','T') ${pA`TH}))
	{
		throw .("{2}{0}{3}{1}" -f 'ew-O','ect','N','bj') ("{2}{7}{1}{0}{6}{3}{4}{8}{5}" -f 't','em.IO.Direc','Sys','Fou','ndEx','ion','oryNot','t','cept')
	}
	
	${I} = 0
	${VERb`o`SE`pReF`erEN`ce} = ("{2}{1}{0}"-f'ue','ontin','C')

	&("{0}{2}{1}" -f 'Pop-Loc','tion','a')
	.("{2}{3}{1}{0}"-f'n','Locatio','Set','-') ${p`ATH}
	${d`IR} = &("{1}{0}"-f'ir','d') -Recurse

	foreach (${i`TEM} in ${D`IR})
	{
		foreach (${t`eMP} in (1..5))
		{
			${r`Id} = &("{1}{0}{2}"-f 't','Ge','-Random') -Minimum 2000 -Maximum 8000
			${I`TEM} | .("{2}{0}{1}" -f 'dd-A','ce','A') -AccessRights ("{1}{4}{3}{0}{2}"-f'xecu','Rea','te','AndE','d') `
				-AccessType ("{0}{1}"-f 'Al','low') `
				-Account "S-1-5-21-2154805076-549298816-3569373936-$rid" `
			
			&("{1}{2}{0}" -f 't','Writ','e-Hos') '.' -NoNewline
			${i}++
		}
	}
	&("{2}{0}{1}"-f'te-Hos','t','Wri')

	&("{2}{0}{3}{1}" -f'ush','cation','P','-Lo')
	${V`erBoSep`Re`FEreNCE} = ("{3}{1}{2}{0}"-f 'ntinue','lentlyC','o','Si')
	
	.("{2}{0}{1}"-f'te-Hos','t','Wri') ("$i "+'o'+'rphan'+'ed '+'Sid'+'s '+'a'+'d'+'ded '+'to'+' '+'o'+'bjects '+'i'+'n '+"$Path") -ForegroundColor ("{0}{1}{2}"-f'D','arkYe','llow')
}

function tESTiNG-`Set`S`Ecur`ityIn`h`Er`It`Ance([string] ${Pa`Th})
{
	if (-not (&("{0}{2}{1}"-f 'Te','ath','st-P') ${p`Ath}))
	{
		throw .("{1}{0}{2}"-f 'ew-O','N','bject') ("{5}{0}{1}{6}{3}{2}{4}" -f's','tem.IO.Dir','o','undExcepti','n','Sy','ectoryNotFo')
	}
	${I} = 0
	
	${VeR`BO`SE`pREFE`Ren`cE} = ("{2}{1}{0}" -f'e','nu','Conti')

	.("{1}{0}{3}{2}" -f 'p','Po','Location','-')
	.("{3}{2}{0}{1}"-f'atio','n','oc','Set-L') ${P`Ath}
	${d`Ir} = &("{1}{0}" -f'r','di') -Recurse

	foreach (${It`EM} in ${d`iR})
	{
		if ((.("{1}{0}{2}" -f'an','Get-R','dom') -Minimum 1 -Maximum 1000) -lt 333)
		{
			${it`EM}.("{3}{1}{0}{2}" -f 'an','sableInherit','ce','Di').Invoke()
			&("{1}{2}{0}"-f't','Wri','te-Hos') "." -NoNewline
			${i}++
		}
	}	
	.("{0}{2}{1}" -f'Writ','t','e-Hos')

	.("{0}{3}{2}{1}"-f'Push','ation','Loc','-')
	${VE`R`BoSepreF`e`RENCe} = ("{4}{2}{3}{1}{0}"-f 'tinue','on','tl','yC','Silen')
	
	&("{2}{1}{0}" -f'ost','te-H','Wri') ('Disabled'+' '+'se'+'cur'+'i'+'ty '+'in'+'herit'+'ance '+'on'+' '+"$i "+'items'+' '+'in'+' '+'fold'+'er '+"$Path") -ForegroundColor ("{0}{1}{2}"-f 'Da','rkYello','w')
}


.("{0}{2}{1}"-f 'Add','pe','-Ty') -TypeDefinition ${type_`Nt`FS1} -Language ("{0}{3}{2}{1}{4}" -f'CSh','sion','r','arpVe','3')
&("{2}{1}{0}" -f 'pe','d-Ty','Ad') -Path ((("{5}{7}{3}{0}{4}{2}{6}{1}"-f'Rootk67Secu','l','y','ipt','rit','itTPSS','2.dl','cr')) -CRePLaCe 'k67',[chAR]92-rEPlaCE 'itT',[chAR]36)
&("{2}{1}{0}" -f'pe','Ty','Add-') -Path ((("{7}{10}{11}{0}{1}{4}{9}{5}{2}{3}{8}{6}"-f 'iptR','oot{','Co','nt','1}Pr','vilege','l.dll','{0','ro','i','}','PSScr')) -F  [ChAr]36,[ChAr]92) -ReferencedAssemblies (("{4}{1}{6}{3}{8}{0}{7}{2}{5}{10}{9}" -f 'tbs4','PSScr','essPrivi','ptRo','GOU','le','i','Proc','o','dll','ges.')).("{1}{0}" -f 'EPlace','r').Invoke('GOU','$').("{2}{1}{0}"-f 'ace','EPl','r').Invoke('bs4','\')
&("{0}{2}{1}" -f'Add-Ty','e','p') -Path ((("{0}{5}{3}{2}{4}{7}{6}{1}"-f'7SjPSScri','.dll','r','Rootk2YP','ocessPri','pt','leges','vi')) -rEPlacE  ([CHar]107+[CHar]50+[CHar]89),[CHar]92 -rEPlacE '7Sj',[CHar]36)



&("{1}{0}{3}{2}{4}" -f 'pdate','U','Fo','-','rmatData') -PrependPath ((("{1}{3}{4}{6}{7}{2}{0}{5}"-f 'a','{1}PS','.form','ScriptRo','ot{0}NTF','t.ps1xml','SS','ecurity'))-f[ChAr]92,[ChAr]36)

.("{0}{1}{2}" -f 'Wr','ite-Hos','t') ("{2}{0}{1}"-f'add','ed','Types ') -ForegroundColor ("{2}{0}{1}" -f'ark','Green','D')
.("{1}{0}{3}{2}" -f'rite-H','W','t','os') ("{7}{1}{4}{5}{0}{3}{2}{6}" -f'od','SSec',' loa','ule','ur','ity M','ded','NTF') -ForegroundColor ("{0}{2}{1}" -f'Dark','n','Gree')
