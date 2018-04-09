Invoke-Command powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# $L Choose the Directory Path of your output Notice $home = c:\users\YOUrUser (This is a reserved Variable by default into Windows)

$L = "$Home\Documents\telly\tests"
if (!(test-path $L)) { mkdir $L}
Set-Location "$L"
$Directory = Get-Location

$tellyURL = "https://github.com/tombowditch/telly/releases/download/v0.4.5/telly-windows-amd64.exe"
$m3u_editor_url = "https://github.com/jjssoftware/m3u-epg-editor/archive/tvhoffset.zip"
# 
Write-Output "
                            Checking if you have telly downloaded
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
            $L\telly.exe             
              "
# look in the telly directory for latest current versions
if (!(Test-Path $L\telly.exe)) {
    Write-Output "
    
                                Downloading telly v0.4.5
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
            $L\telly.exe             
              "

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $tellyURL -OutFile "$L\telly.exe" -PassThru -ErrorAction SilentlyContinue
}
Else {
    #
    Write-Output "
                                    telly v0.4.5
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
            *********************** Already Downloaded ***********************
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------                               
            $L\telly.exe              
            "
}
####################################################################################
Write-Output "
                        Checking if you have m3u-epg-editor downloaded
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
            $L\m3u-epg-editor-tvhoffset                                                       
              "

# look in the telly directory for latest current versions
if (!(Test-Path "$L\m3u-epg-editor-tvhoffset")) {
    Write-Output "
    
                                Downloading m3u-epg-editor
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
                                NEW DIRECTORY CREATED
            $L\m3u-epg-editor-tvhoffset

              "

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest $m3u_editor_url -OutFile "$L\m3u-epg-editor-tvhoffset.zip" -PassThru -ErrorAction SilentlyContinue
    Expand-Archive "$L\m3u-epg-editor-tvhoffset.zip" -DestinationPath $L -ErrorAction SilentlyContinue
    Remove-Item -Path "$L\m3u-epg-editor-tvhoffset.zip" -Force 
}
else {
  

    #
    Write-Output "
                                    m3u-epg-editor
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
            *********************** Already Downloaded ***********************
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------                              
            $L\m3u-epg-editor-tvhoffset
            "
}
#########################################################################################
# Checking if Python 2.7 is installed
if (!(Test-Path "C:\Python27\python.exe")) {
    Write-Output "           
            **************** Please download Python 2.7.14 *******************    
            ------------------------------------------------------------------
            =========================LINK BELLOW==============================
            ------------------------------------------------------------------
             https://www.python.org/ftp/python/2.7.14/python-2.7.14.amd64.msi
            ------------------------------------------------------------------
            ==================================================================
            ------------------------------------------------------------------
                "

    Exit-PSHostProcess
}
else {
    #  1 set your location of the m3u editor
    $1 = "$L\m3u-epg-editor-tvhoffset"
    
    # Live TV
    #$Vaders2 = "http://api.vaders.tv/vget?username=YOUR_USERNAME&password=YOUR_PASSWORD&format=ts" # Original DOESN'T WORK FOR TELLY
    # B Set your epg
    #$VadersEPG_VOD = "http://vaders.tv/p2.xml.gz"
    #
    # VOD & Live TV

    $Vaders2 = Read-Host "Plese include your M3U URL or M3U Local File like this: file:///C:\your\file\path" # You can change this for FABI IPTV or any other Local File
    # B Set your epg
    $VadersEPG_VOD = Read-Host "Please include your Vaders VOD EPG i.e http://vaders.tv/xmltv.php?username=usr&password=pass"
    # uncomment below to not show the message <#
    
    Write-Output  "
    ChannelGroups = Original groups founds in Vader's M3U these could change
    in time to time, please check your M3U in case of any error
    ChannelGroups =   'afghani'	,
                      'arabic'	,
                      'bangla'	,
                      'canada'	,
                      'filipino'	,
                      'france'	,
                      'germany'	,
                      'gujrati'	,
                      'india'	,
                      'ireland'	,
                      'italy'	,
                      'korea'	,
                      'latino'	,
                      'live events'	,
                      'malayalam'	,
                      'marathi'	,
                      'pakistan'	,
                      'portugal'	,
                      'premium movies',
                      'punjabi'	,
                      'scandinavian',
                      'spain'	,
                      'sports'	,
                      'tamil'	,
                      'telugu'	,
                      'thai'	,
                      'united kingdom',
                      'united states',
                      'united states - regionals',
                      'Live Events',
                      'Movies',
                      '4K Movies',	
    "
    
    <# Add your channels or channel groups manually as showed below for direct automation and uncomment it
     $ChannelGroups = "'sports','ireland'"
     Comment with # the line bellow #$GC = Read-Host "" & #$ChannelGroups = "$CG" if you do not want user prompt
     and uncomment the above  $ChannelGroups = "'Your','Channels'"
     #>
    
    $CG = Read-Host "Please enter your 'groups','Channels' in this way or as you can see above"
    $ChannelGroups = "$CG"  

    # G Choose the desired file name for the sorted and filter M3U8 File obtained from mpg-editor
    $DG = "$Directory\Sorted"
    if (!(test-path $DG)) { mkdir $DG}
    $G = "$DG\Sorted"
    
   
    
    #
    Write-Output "Starting to downloand and sort the channels and groups appropiately"
    # This will Sort the Groups and Channels and add a channel number for each group starting from 1
    C:\Python27\python.exe $1\m3u-epg-editor.py --sortchannels --tvh_offset=100 --m3uurl="$Vaders2" -e="$VadersEPG_VOD" -g "$ChannelGroups" --channels="$no_epg_channels" --outdirectory="$DG" --outfilename="$G"
    #

    # This is your output Sorted File from mpg-editor
    $Sorted_m3u = "$G.m3u8"
    if ((Get-Content $Sorted_m3u) -match ":80") {
        (get-content $Sorted_m3u) -replace ":80", "" | Set-Content $Sorted_m3u # Replace the :80 from the streams if exist
    }
    else {
        write-host 'Nothing to replace in the file, Continue...'
    }

    # This is the original file downloaded
    $Original_m3u = "$DG\original.m3u8"
    if ((Get-Content $Original_m3u) -match ":80") {
        (get-content $Original_m3u) -replace ":80", "" | Set-Content $Original_m3u # Replace the :80 from the streams if exist
    }
    else {
        write-host 'Nothing to replace in the file, Continue...'
    }


    $Original_Local = "file:///$Original_m3u" # alt you can use the original file downloaded for manual teak of the lines below
    $Sorted_m3u_Local = "file:///$Sorted_m3u" # By preference I choose the already sorted file
   

    <# Filter the undesired channels (you can take this ones running the epg-ditor once with or without the Groups {$ChannelGroups} above to see the NON-EPG channel list as shown {$uc})
    $no_epg_channels = "'26 tv hd','a&e lt hd','amc lt hd','axn lt hd','animal planet hd lt','azteca 13','azteca 7','bandamax lt','cbn hd','cbs news hd','cbs sports hq','cnn lt','canal 11','canal de las estrellas','cinecanal','comedy central lt','de pelicula','discovery channel lt hd','discovery civilization','discovery home & health','discovery science lt','discovery theater','discovery turbo lt','disney jr lt','disney lt hd','disney xd lt','e! lt','espn 2 lt','espn 3 lt','espn lt','fight tyme','fox action lt','fox cinema lt','fox movies lt','fox sports 2 lt hd','fox sports 3 lt hd','fox sports carolina hd','fox sports indiana hd','fox sports lt hd','fox sports south georgia hd','fox sports south georgia hd','fox sports tennessee hd','fox sports tennessee hd','galavision hd','hbo family lt hd','hbo lt hd','hbo plus lt hd','hbo signature lt hd','history lt hd','mimusica hd','nbc philadelphia','nbc universo 2 hd','nbc universo 2 hd','nbc universo hd','nbc universo hd','nat geo lt','nat geo wild lt','osn cricket hd','rds 2','sony lt','spectrum sportsnet hd','spectrum sportsnet la hd','tva sports hd','telemundo los angeles hd','unimas hd','univision miami hd'"
    #>
    $no_epg_channels = Get-Content "$DG\no_epg_channels.txt"
    
    $SC = "$DG\sorted.channels.txt"                             # Channels from A-Z
    $SCNG = "$DG\sorted.channels.nogroup.txt"                   # Channels from A-Z without Group
    $HD = "$Directory\HD"
    
    # Create a new directory to add the HD m3u playlist
    if (!(test-path $HD)) { mkdir $HD}
    $filename_hd = "$HD\hd.channels.only.txt"                   # No SD Channels List
    
    $SD = "$Directory\SD"
    # Create a new directory to add the SD m3u playlist
    if (!(test-path $SD)) { mkdir $SD}
    $filename_sd = "$SD\sd.channels.only.txt"       # No HD Channels List
    #
    $IPTVSD = "$SD\SDTv.unique.txt"            # SD Channels List without Duplicates
    $IPTVHD = "$HD\HDTv.unique.txt"            # HD Channels List without Duplicates
    
    (get-content $SC) -replace "$CG", "" | out-file "$SCNG"
    
    (get-content $SCNG) -notmatch "hd" | out-file $filename_sd
    get-content $filename_sd | Sort-Object    | get-unique > $IPTVSD
    
    # replace the last (,) of the files
    $replaceCharacter = '' # delete at the end of the channels file which is generally (,)
    
    $contentSD = Get-Content $IPTVSD
    $contentSD[-1] = $contentSD[-1] -replace '^(.*).$', "`$1$replaceCharacter"
    $contentSD | Set-Content $IPTVSD 

    (get-content $scng) -match "hd" | out-file $filename_hd
    get-content $filename_hd | Sort-Object | get-unique > $IPTVHD
    # replace the las (,) of the files
    $contentHD = Get-Content $IPTVHD
    $contentHD[-1] = $contentHD[-1] -replace '^(.*).$', "`$1$replaceCharacter"
    $contentHD | Set-Content $IPTVHD
    
    $gcSD = Get-Content $IPTVSD
    $gcHD = Get-Content $IPTVHD
    
    
    # $I give an output filename of the sorted and cleanead duplicated channels for HD .m3u8 list  
    $I = "$HD\HDTv"
    
    # $K Give an output filename of the sorted and cleaned duplicated channels for SD .m3u8 list
    $K = "$SD\SDTv"
 
    $message = 'Step 1 complete, Cool! *_0'
    $question = 'Would you like to create a separate folder with HD Channels only?'
      
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
      
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        #Filter the File one more time with the HD or SD Channels (This step is optional, i like to get HD and SD Channels Separately)
        C:\Python27\python.exe $1\m3u-epg-editor.py --sortchannels --tvh_offset=100 --m3uurl="$Sorted_m3u_Local" -e="$VadersEPG_VOD" -g "$ChannelGroups" --channels="$no_epg_channels,$gcSD" --outdirectory="$HD" --outfilename="$I"
        # $HDTv final HD iptv m3u8
        $HDTv = "$HD\HDTv.m3u8"
        Remove-Item "$HD\original.*"

        if ((Get-Content $HDTv) -match ":80") {
            (get-content $HDTv) -replace ":80", "" | Set-Content $HDTv # Replace the :80 from the streams if exist
        }
        Else {
            write-host 'Nothing to replace in the file, Continue...'
        }
    }
    else {
        Write-Host 'Ok no HD Then...'
    }
  
    $message = 'Step 2 to create an even better sorting'
    $question = 'Would you like to create a separate folder with SD Channels only?'
  
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
  
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'Cool!'
      
        # Change it accordindly to your Directory path - I Suggest have everything on the same folder as $home\Documents <IT'S YOUR CHOICE>
        C:\Python27\python.exe $1\m3u-epg-editor.py --sortchannels --tvh_offset=100 --m3uurl="$Sorted_m3u_Local" -e="$VadersEPG_VOD" -g "$ChannelGroups" --channels="$no_epg_channels,$gcHD" --outdirectory="$SD" --outfilename="$K"
        # $SDTv final SD iptv m3u8
        $SDTv = "$SD\SDTv.m3u8"
        Remove-Item "$SD\original.*"
        if ((Get-Content $SDTv) -match ":80") {
            (get-content $SDTv) -replace ":80", "" | Set-Content $SDTv # Replace the :80 from the streams if exist
        }
        else {
            write-host 'Nothing to replace in the file, Continue...'
        }
  
    }    
    # Move all the Original files to one folder as "Original"
    $Original = "$Directory\Original"
    if (!(test-path $Original)) { mkdir $Original}
    Move-Item "$DG\original.*" -Destination $Original -Force

    ##########################################################################################
    # Questions Time #



    $message = '...Telly Scripts Time as Come...'
    $question = 'Would you like to Run Telly with the sorted channels?'
      
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
      
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        
        Write-Output "Set-Location ""$Directory""
        .\telly.exe -listen 127.0.0.1:9077 -playlist=""$($Sorted_m3u)"" -temp ""$Directory"" -streams 5 -friendlyname ""Sorted_Channels"" -deviceid ""10000009"" -logrequests" | set-content $L\telly_Sorted.ps1

        Start-Process -FilePath "$L\telly_Sorted.ps1"

    }
    else {
        Write-Host 'OK...'
    }
    $message = '0_o'
    $question = 'Would you like to Run Telly with the HD channels?'
      
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
      
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        Write-Output "Set-Location ""$Directory""
        .\telly.exe -listen 127.0.0.1:8077 -playlist=""$($HDTv)"" -temp ""$Directory"" -streams 5 -friendlyname ""HDTv"" -deviceid ""10000008"" -logrequests" | set-content $L\telly_HD.ps1

        Start-Process -FilePath "$L\telly_HD.ps1"
       
    }
    else {
        Write-Host 'OK...'
    }
    $message = '...0_0'
    $question = 'Would you like to Run Telly with the SD channels?'
      
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
      
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        Write-Output "Set-Location ""$Directory""
        .\telly.exe -listen 127.0.0.1:7077 -playlist=""$($SDTv)"" -temp ""$Directory"" -streams 5 -friendlyname ""SDTv"" -deviceid ""10000007"" -logrequests" | set-content $L\telly_SD.ps1

        Start-Process -FilePath "$L\telly_SD.ps1"

    }
    else {
        Write-Host '-_-'
    }    
}
Exit-PSHostProcess

<# Manual Telly Scripts for reference
      # Some code
      # Run Telly with the correct iptv.m3u8 file of your preference $Sorted_m3u (HD and SD included) or $HDTv (HD Only) $SDTv (SD Only)
      #  
      # uncomment bellow for HDTv 
      #.\telly.exe -listen 127.0.0.1:9077 -playlist="$HDTv" -temp $Directory -streams 5 -friendlyname "HDTv" -deviceid "10000009" -logrequests
      #
      # uncomment bellow for SDTv
      #telly-windows-amd64.exe -listen 127.0.0.1:8077 -playlist="$SDTv" -temp $Directory -streams 5 -friendlyname "SDTv" -deviceid "10000008" -logrequests
      #
      # uncomment bellow for HDTv and SDTv
      #
      #telly-windows-amd64.exe -listen 127.0.0.1:7077 -playlist="$Sorted_m3u" -temp $Directory -streams 5 -friendlyname "HD_SD_TV" -deviceid "10000007" -logrequests
      #
      # uncomment bellow for original.m3u8 file
      #telly-windows-amd64.exe -listen 127.0.0.1:6077 -playlist="$Original_m3u" -temp "$Directory\vaders1" -streams 5 -friendlyname "Original" -deviceid "10000006" -logrequests
      #
      # Uncomment bellow for external m3u working
      #telly-windows-amd64.exe -listen 127.0.0.1:5077 -playlist="plus.m3u" -streams 5 -temp "$Directory\external" -uktv -friendlyname "External" -deviceid "10000005" -logrequests
      #    
      #>
      
#>
