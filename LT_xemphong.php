
<?php 
session_start();

if (isset($_SESSION['id']) && isset($_SESSION['hovaten'])) {

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
     include '/xampp/htdocs/hotel/connect.php';
     $id=$_GET['phongid'];
     $result=pg_query($conn,"SELECT * FROM thuephong NATURAL JOIN khachhang WHERE phong_id='$id' AND (tg_layphong<=CURRENT_TIMESTAMP AND tg_traphong>=CURRENT_TIMESTAMP)");
     $row=pg_fetch_assoc($result);
?>
<form class="form">
    <label style="color:black;"> Phòng : <?php echo $id; ?></label><br>
     <label> Họ và tên : <?php echo $row['hovaten']; ?></label><br>
     <label> Số điện thoại : <?php echo $row['sdt']; ?></label><br>
     <label> Thời gian lấy phòng : <?php echo $row['tg_layphong']; ?></label><br>
     <label> Thời gian trả phòng : <?php echo $row['tg_traphong']; ?></label><br>

     
     <a href="./LT_QL_phong.php" class="ca">
          Trở lại
     </a>
</form>
</body>
<script src="asset/css/trangchu.js"></script>

</html>
<?php 
}else{
     header("Location: index.php");
     exit();
}
 ?>