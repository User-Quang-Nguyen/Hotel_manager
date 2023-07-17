<?php 
session_start(); 
include "connect.php";

if (isset($_POST['uname']) && isset($_POST['password'])) {

	function validate($data){
       $data = trim($data);
	   $data = stripslashes($data);
	   $data = htmlspecialchars($data);
	   return $data;
	}

	$uname = validate($_POST['uname']);
	$pass = validate($_POST['password']);
	$nhanvien = validate($_POST['nhanvien']);
	if (empty($uname)) {
		header("Location: index.php?error=User Name is required");
	    exit();
	}else if(empty($pass)){
        header("Location: index.php?error=Password is required");
	    exit();
	}else{
			$sql = "SELECT * FROM khachhang WHERE uname='$uname' AND pass='$pass'";
		if($nhanvien==1){
			$sql = "SELECT * FROM nhanvien WHERE uname='$uname' AND pass='$pass'AND chucvu='Lễ tân'";
		}elseif($nhanvien==2){
			$sql = "SELECT * FROM nhanvien WHERE uname='$uname' AND pass='$pass'AND chucvu='Quản lí'";
		}
			

		$result = pg_query($conn, $sql);
		
		if (pg_num_rows ($result) === 1) {
			$row = pg_fetch_assoc($result);
            
            	$_SESSION['uname'] = $row['uname'];
            	$_SESSION['hovaten'] = 	$row['hovaten'];
				$_SESSION['nhanvien'] = $nhanvien;
				if($nhanvien==1){
					$_SESSION['id'] = 		$row['nv_id'];
					header("Location: LT_trangchu.php");
					exit();
				}elseif($nhanvien==2){
					$_SESSION['id'] = 		$row['nv_id'];
					header("Location: QL_trangchu.php");
					exit();
				}else{
					$_SESSION['id'] = 		$row['kh_id'];
					header("Location: KH_trangchu.php");
					exit();
				}
            	
		        

			
		}else{
			header("Location: index.php?error=Tài khoản hoặc mật khảu không chính xác");
	        exit();
		}
	}
	
}else{
	header("Location: index.php");
	exit();
}
