<?php 
  # decrypt RJ-256
  # USAGE decrypt-rijndael-256.php [B64 BUNDLE] [B64 API]
  if (count($argv) < 3)
  {
        echo "decrypt-rijndael-256.php [B64 BUNDLE] [B64 API]\n";
        exit;
  }

  $bundled = base64_decode($argv[1]);
  $api = base64_decode($argv[2]);

  # echo "API: '$api'";

  $iv = substr($bundled, 0, 32);
  $pw = substr($bundled, 32);

  $alg = "rijndael-256";
  $mode = 'ctr';

  $plaintext = mcrypt_decrypt($alg, $api, $pw, $mode, $iv);
  print $plaintext;
?>