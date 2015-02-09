<?php
	// ## $Id$ ##
	// require ("config.inc.php");
	// require ("functions.inc.php");
	include "ldap.inc.php";
	// include "ihm.inc.php";
        
        
        // HTMLpurifier
        include("../se3/includes/library/HTMLPurifier.auto.php");
        $config = HTMLPurifier_Config::createDefault();
        $purifier = new HTMLPurifier($config);
  
        $computername=isset($_GET['computername']) ? $purifier->purify($_GET['computername']) : "";
        $username=isset($_GET['username']) ? $purifier->purify($_GET['username']) : "";
        $userdomain=isset($_GET['userdomain']) ? $purifier->purify($_GET['userdomain']) : "";

	$PathProfileJs = "/var/se3/unattended/install/packages/firefox/firefox-profile.js";
	$PathProfileSe3Js = "/var/se3/unattended/install/packages/firefox/firefox-profile-se3.js";
	$filename = basename ($PathProfileJs);
	if (file_exists($PathProfileSe3Js) ) {
		$DateFichier = gmdate("D, d M Y H:i:s T", filemtime("$PathProfileSe3Js"));
	} else {
		$DateFichier = gmdate("D, d M Y H:i:s T", filemtime("$PathProfileJs"));
	}
	header("Content-type: application/x-javascript");
	header("Last-Modified: $DateFichier");
	header("Expires: " . gmdate("D, d M Y H:i:s T", time() + 5));
	header("Pragma: no-cache");
	header("Cache-Control: max-age=5, s-maxage=5, no-cache, must-revalidate");
	header("Content-Disposition: inline; filename=$filename");
	echo "//BEGIN CE prefs\r\n";
	echo "\r\n";
	echo "try {\r\n";
	if ( isset($computername) ) {
		echo "  computername = '$computername';\r\n";
		$parc = search_parcs ($computername);
		$nParc = count( $parc);
		echo "  parcs = ',";
		for ($i=0; $i<$nParc; $i++) {
			echo $parc[$i]["cn"] . "," ;
		}
		echo "';\r\n";
	}
	if ( isset($username) ) {
		echo "  username = '$username';\r\n";
		$filtre = "(|(memberUid=".$username.")(member=uid=".$username.",".$dn['people']."))";
		$userGroups = search_groups ( $filtre );
		$nGroups = count( $userGroups);
		echo "  userGroups = ',";
		for ($i=0; $i<$nGroups; $i++) {
			echo $userGroups[$i]["cn"] . "," ;
		}
		echo "';\r\n";
	}
	if ( isset($userdomain) ) {
		echo "  userdomain = '$userdomain';\r\n";
	}
	echo "} catch(e) {\r\n";
	echo "  displayError('firefox-profile.php', e);\r\n";
	echo "}\r\n";
	echo "\r\n";
	readfile("$PathProfileJs");
	if (file_exists($PathProfileSe3Js) && isset($computername) && isset($username)  && isset($userdomain) ) {
		// Ajout du param�trage d�fini par l'interface web du se3
		readfile("$PathProfileSe3Js");
	}
?>
