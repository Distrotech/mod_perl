package TestAPRlib::threadmutex;

use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;

use APR::Const -compile => qw(EBUSY SUCCESS);
use APR::Pool();

sub num_of_tests {
    return 5;
}

sub test {

    require APR::ThreadMutex;

    my $pool = APR::Pool->new();
    my $mutex = APR::ThreadMutex->new($pool);

    ok $mutex;

    ok t_cmp($mutex->lock, APR::SUCCESS,
             'lock == APR::SUCCESS');

#XXX: don't get what we expect on win23
#need to use APR_STATUS_IS_EBUSY ?
#    ok t_cmp($mutex->trylock, APR::EBUSY,
#             'trylock == APR::EBUSY');

    ok t_cmp($mutex->unlock, APR::SUCCESS,
             'unlock == APR::SUCCESS');

    # out-of-scope pool
    {
        my $mutex = APR::ThreadMutex->new(APR::Pool->new);
        # try to overwrite the temp pool data
        require APR::Table;
        my $table = APR::Table::make(APR::Pool->new, 50);
        $table->set($_ => $_) for 'aa'..'za';
        # now test that we are still OK
        ok t_cmp($mutex->lock, APR::SUCCESS,
                 'lock == APR::SUCCESS');
        ok t_cmp($mutex->unlock, APR::SUCCESS,
                 'unlock == APR::SUCCESS');
    }

}

1;
