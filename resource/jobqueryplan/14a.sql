SELECT MIN(mi_idx.info) AS rating,
       MIN(t.title) AS northern_dark_movie
FROM info_type AS it1,
     info_type AS it,
     keyword AS k,
     kind_type AS kt,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     title AS t
WHERE it1.info = 'countries'
  AND it.info = 'rating'
  AND k.keyword IN ('murder',
                    'murder-in-title',
                    'blood',
                    'violence')
  AND kt.kind = 'movie'
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
                  'German',
                  'USA',
                  'American')
  AND mi_idx.info < '8.5'
  AND t.production_year > 2010
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mi_idx.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id;


Aggregate  (cost=7436.87..7436.88 rows=1 width=64)
  ->  Nested Loop  (cost=8.07..7436.86 rows=1 width=22)
        Join Filter: (mi.info_type_id = it1.id)
        ->  Nested Loop  (cost=8.07..7434.44 rows=1 width=26)
              Join Filter: (t.id = mi.movie_id)
              ->  Nested Loop  (cost=7.64..7432.51 rows=1 width=34)
                    Join Filter: (mi_idx.info_type_id = it.id)
                    ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                          Filter: ((info)::text = 'rating'::text)
                    ->  Nested Loop  (cost=7.64..7429.98 rows=9 width=38)
                          Join Filter: (t.id = mi_idx.movie_id)
                          ->  Nested Loop  (cost=7.21..7428.38 rows=3 width=25)
                                Join Filter: (t.kind_id = kt.id)
                                ->  Seq Scan on kind_type kt  (cost=0.00..1.09 rows=1 width=4)
                                      Filter: ((kind)::text = 'movie'::text)
                                ->  Nested Loop  (cost=7.21..7427.03 rows=21 width=29)
                                      ->  Nested Loop  (cost=6.78..7361.15 rows=135 width=4)
                                            ->  Seq Scan on keyword k  (cost=0.00..2961.55 rows=4 width=4)
                                                  Filter: ((keyword)::text = ANY ('{murder,murder-in-title,blood,violence}'::text[]))
                                            ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1096.87 rows=303 width=8)
                                                  Recheck Cond: (keyword_id = k.id)
                                                  ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                        Index Cond: (keyword_id = k.id)
                                      ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=25)
                                            Index Cond: (id = mk.movie_id)
                                            Filter: (production_year > 2010)
                          ->  Index Scan using movie_id_movie_info_idx on movie_info_idx mi_idx  (cost=0.43..0.50 rows=3 width=13)
                                Index Cond: (movie_id = mk.movie_id)
                                Filter: ((info)::text < '8.5'::text)
              ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..1.90 rows=2 width=8)
                    Index Cond: (movie_id = mk.movie_id)
                    Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Denish,Norwegian,German,USA,American}'::text[]))
        ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
              Filter: ((info)::text = 'countries'::text)
