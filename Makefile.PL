use inc::Module::Install;

name            'Die-Retry';
all_from        'lib/Die/Retry.pm';
author          'Bradley Dean <bjdean@bjdean.id.au>';

test_requires   'Test::More';

auto_install;

WriteAll;

