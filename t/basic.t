#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::Most;

lives_ok { require Simple } 
    'simple usage works';

throws_ok { require CircleA } qr/circular loading of class 'CircleA_Foo'/i, 
    'circular loading packages throw error';

done_testing;
