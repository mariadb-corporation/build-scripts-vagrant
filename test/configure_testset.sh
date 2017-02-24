if [ "$test_set_labels" != "" ] ; then
        test_set_labels_L=`echo "$test_set_labels" | sed "s/,/  /g"`
        export test_set=`echo "-L $test_set_labels_L"`
fi
echo "Test set is '$test_set'"

