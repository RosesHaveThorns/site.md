<?php

// THIS TEMPLATE IS USED BY SITE.MD

// MAKE CHANGES AS REQUIRED TO FIT YOUR
// SITE ORGANISATION SUCH AS INCLUDING A
// HEADER AND FOOTER TEMPLATE OR ADDING
// A NAVIGATION PANE

  // load config for this directory
    $json_file = file_get_contents("sitemd_dir.json");
    if ($json_file === false) {
        echo "ERROR No directory config file found";
        die();
    }
    $sitemd = json_decode($json_file, true);

  // When accessing directories outside of you site.md directory from this file,
  // Do so relative to the root site.md directory using the variable:
	// $sitemd['root_dir']
?>

<body>
	<?php
      // load and show markdown file of same name as this file
  
        $Parsedown = new Parsedown();
        $Parsedown->setSafeMode(true);

        if (file_exists($page['name'].'.md')) {
            $markdown = file_get_contents($page['name'].'.md');
            echo $Parsedown->text($markdown);
        } 
        else {
            echo "<h2>MARKDOWN FILE MISSING</h2><p>Please Contact Site Administrator</p>";
        }
    ?>
</body>
