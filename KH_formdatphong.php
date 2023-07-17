<?php
include './connect.php';
?>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Document</title>
  <link rel="stylesheet" href="asset/css/dangnhap.css" />
  <link rel="stylesheet" href="asset/css/themify-icons/themify-icons.css" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  

<body>


<?php
     $id=$_GET['id'];
     $phong_id=$_GET['phong_id'];
     $layphong=$_GET['layphong'];
     $traphong=$_GET['traphong'];

$sql = "INSERT INTO thuephong(kh_id,phong_id,tg_layphong,tg_traphong) VALUES ('$id','$phong_id','$layphong','$traphong');";
if(pg_query($conn,$sql)==true){
     header("Location: KH_datphong.php?success=Đặt phòng thành công");
     exit();
}else{
     header("Location: KH_datphong.php?error= Thất bại ");
     exit();
}


?>
</form>
</body>
<script src="asset/css/trangchu.js"></script>

</html>