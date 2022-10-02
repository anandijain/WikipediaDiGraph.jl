
mkdir data
wget https://dumps.wikimedia.org/enwiki/20220920/enwiki-20220920-page.sql.gz
wget https://dumps.wikimedia.org/enwiki/20220920/enwiki-20220920-pagelinks.sql.gz

gzip -d enwiki-20220920-page.sql.gz
gzip -d enwiki-20220920-pagelinks.sql.gz

mv enwiki-20220920-page.sql data/
mv enwiki-20220920-pagelinks.sql data/
