<?php
    $ip="0.0.0.0";
    if (isset($_POST['submit'])){
	$ip = $_POST['ip'];
        $result = system("ping " . $ip);
        echo $result;
    }
?>

<html>
<head>
 <title>PHP Test</title>
</head>
<body>

<form action="" method="post">
 IP Address: <input type="text" name="ip" value="<?php echo 
 $ip;?>">
<input type="submit" name="submit" value="Ping me!" />
</form>
</body>
</html> 

