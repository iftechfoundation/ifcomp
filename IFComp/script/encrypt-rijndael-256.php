<?php 
  # encrypt RJ-256
  # USAGE encrypt-rijndael-256.php [PLAINTEXT]  [B64 API]
  if (count($argv) < 3)
  {
        echo "encrypt-rijndael-256.php [PLAINTEXT]  [B64 API]\n";
        exit;
  }
 
  $plaintext = $argv[1];
  # echo "PT: $plaintext\n";

  $api = base64_decode($argv[2]);
  # echo "API: '$api'\n";

  $iv = mcrypt_create_iv(32,MCRYPT_DEV_RANDOM);
  # echo "IV: '$iv'\n";

  $alg = "rijndael-256";
  $mode = 'ctr';
  # echo "Calculating\n";

  $raw = mcrypt_encrypt($alg, $api, $plaintext, $mode, $iv);
  echo base64_encode($iv . $raw);
?>