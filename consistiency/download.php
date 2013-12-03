<?php
 $dir="targets/update/v1/Tails/0.21/i386/stable/";
 if (isset($_REQUEST["file"])) {
     if(file_exists($dir.$_REQUEST["file"])) {
     	$file = $dir.$_REQUEST["file"];
	    header("Content-type: application/force-download");
	    header("Content-Transfer-Encoding: Binary");
	    header("Content-length: ".filesize($file));
	    header("Content-disposition: attachment; filename=\"".basename($file)."\"");
	    readfile("$file");
	}
	else {
		echo "File does not exist, or is currently updating, please try again in 10 minutes.";
	}
 } else {
     echo "No file selected";
 }
 ?>