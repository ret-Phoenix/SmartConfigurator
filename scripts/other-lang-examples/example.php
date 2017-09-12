<?php

function Main() {
	$data = file_get_contents('tmp/module.txt');
	$newdata = strtoupper($data);
	file_put_contents('tmp/module.txt',$newdata);
}

main();

?>