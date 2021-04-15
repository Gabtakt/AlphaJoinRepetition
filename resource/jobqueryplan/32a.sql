SELECT MIN(lt.link) AS link_type,
       MIN(t1.title) AS first_movie,
       MIN(t.title) AS second_movie
FROM keyword AS k,
     link_type AS lt,
     movie_keyword AS mk,
     movie_link AS ml,
     title AS t1,
     title AS t
WHERE k.keyword = '10,000-mile-club'
  AND mk.keyword_id = k.id
  AND t1.id = mk.movie_id
  AND ml.movie_id = t1.id
  AND ml.linked_movie_id = t.id
  AND lt.id = ml.link_type_id
  AND mk.movie_id = t1.id;



Aggregate  (cost=3812.07..3812.08 rows=1 width=96)
  ->  Nested Loop  (cost=7.93..3811.99 rows=10 width=46)
        ->  Nested Loop  (cost=7.50..3770.04 rows=10 width=33)
              ->  Nested Loop  (cost=7.07..3765.18 rows=10 width=24)
                    Join Filter: (ml.link_type_id = lt.id)
                    ->  Nested Loop  (cost=7.07..3761.50 rows=10 width=16)
                          ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=4)
                                ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=4)
                                      Filter: ((keyword)::text = '10,000-mile-club'::text)
                                ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                      Recheck Cond: (keyword_id = k.id)
                                      ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                            Index Cond: (keyword_id = k.id)
                          ->  Index Scan using movie_id_movie_link on movie_link ml  (cost=0.29..0.38 rows=5 width=12)
                                Index Cond: (movie_id = mk.movie_id)
                    ->  Materialize  (cost=0.00..1.27 rows=18 width=16)
                          ->  Seq Scan on link_type lt  (cost=0.00..1.18 rows=18 width=16)
              ->  Index Scan using title_pkey on title t1  (cost=0.43..0.49 rows=1 width=21)
                    Index Cond: (id = mk.movie_id)
        ->  Index Scan using title_pkey on title t  (cost=0.43..4.20 rows=1 width=21)
              Index Cond: (id = ml.linked_movie_id)
