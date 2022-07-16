<?php
   
	// make a database connection
    $host        = "host = localhost";
    $port        = "port = 5432";
    $dbname      = "dbname = hotel1";
    $credentials = "user = postgres password=12345678";

    $conn = pg_connect( "$host $port $dbname $credentials"  );
    
?>