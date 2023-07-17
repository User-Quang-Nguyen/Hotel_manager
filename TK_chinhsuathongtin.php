
<?php 
session_start();
include './connect.php';
if (isset($_SESSION['id']) && isset($_SESSION['hovaten'])) {
    $id=$_SESSION['id']
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
    
          $ktra=0;
               $result=pg_query($conn,"SELECT * FROM khachhang WHERE kh_id='$id'");
               $row=pg_fetch_assoc($result);
          if(pg_num_rows($result)==0){
               $result=pg_query($conn,"SELECT * FROM nhanvien WHERE nv_id='$id'");
               $row=pg_fetch_assoc($result);
               if($row['chucvu']=='Quản lí') $ktra=2;
               elseif($row['chucvu']=='Lễ tân'){
                    $ktra=1;
               }

          }
     
    
?>
<form method="POST" class="form">
     <h2>Sửa thông tin</h2>
     <?php if (isset($_GET['error'])) { ?>
     		<p class="error"><?php echo $_GET['error']; ?></p>
     	<?php } ?>

          <?php if (isset($_GET['success'])) { ?>
               <p class="success"><?php echo $_GET['success']; ?></p>
          <?php } ?>
     <label> Họ và tên : <input type="text" value="<?php echo $row['hovaten']; ?>" name="name"></label><br/>
     <label> Giới tính : <input type="text" value="<?php echo $row['gioitinh']; ?>" name="gender"></label><br/>
     <label> Ngày sinh : <input type="text" value="<?php echo $row['ngaysinh']; ?>" name="dob"></label><br/>
     <label> Số điện thoại : <input type="text" value="<?php echo $row['sdt']; ?>" name="sdt"></label><br/>
    

     <button type="submit" name="update">Xác nhận</button>
     <?php
          
          if($ktra==0){?>
               <a href="./KH_trangchu.php">Trở lại</a>
          <?php
          }elseif($ktra==2){?>
               <a href="./QL_trangchu.php">Trở lại</a>
          <?php
          }elseif($ktra==1){?>
               <a href="./LT_trangchu.php">Trở lại</a>
        <?php  }
     ?>
<?php
if (isset($_POST['update'])){

     $name=$_POST['name'];
     $gender=$_POST['gender'];
     $dob=$_POST['dob'];
     $sdt=$_POST['sdt'];
// Create connection

// Check connection

     if($ktra==0){
          $sql = "UPDATE khachhang SET hovaten='$name', gioitinh='$gender', ngaysinh='$dob', sdt='$sdt' WHERE kh_id='$id'";
     }else{
          $sql = "UPDATE nhanvien SET hovaten='$name', gioitinh='$gender', ngaysinh='$dob', sdt='$sdt' WHERE nv_id='$id'";
          
     }

if(pg_query($conn,$sql)==true){
     header("Location: TK_chinhsuathongtin.php?success=Chỉnh sửa thành công");
     exit();
}else{
     header("Location: TK_chinhsuathongtin.php?error=Chỉnh sửa thất bại");
     exit();
}
     $conn=NULL;
}
?>
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