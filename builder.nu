let $out = $env.out

mkdir $out


$env.flake | save ($out)/flake.nix
$env.lock | save ($out)/flake.lock
