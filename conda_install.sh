#!/bin/bash

rm $2/conda_success 2>/dev/null
rm -rf $2 2/dev/null

chmod +x $1
$1 -b -p $2 -f
source $2/bin/activate $2 || exit 1

conda install -q -y -c jochym pygtk2 || exit 2
conda install -q -y numpy nomkl lxml || exit 3
conda install -q -y -c mw gtk2       || exit 4
conda install -q -y -c asmeurer pyqt || exit 5
conda install -q -y -c iandh qwt     || exit 6
pip install mako cheetah             || exit 7

touch $2/conda_success
