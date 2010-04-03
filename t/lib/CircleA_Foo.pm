use strict;
use warnings;

package CircleA_Foo;
no circular::loading;

use CircleA_Bar;

1;
