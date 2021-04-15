SELECT MIN(t.title) AS american_movie
FROM company_type AS ct,
     info_type AS it,
     movie_companies AS mc,
     movie_info AS mi,
     title AS t
WHERE ct.kind = 'production companies'
  AND mc.note NOT LIKE '%(TV)%'
  AND mc.note LIKE '%(USA)%'
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
  AND t.production_year > 1990
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND mc.movie_id = mi.movie_id
  AND ct.id = mc.company_type_id
  AND it.id = mi.info_type_id;



Finalize Aggregate  (cost=91690.01..91690.02 rows=1 width=32)
  ->  Gather  (cost=91689.80..91690.01 rows=2 width=32)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=90689.80..90689.81 rows=1 width=32)
              ->  Hash Join  (cost=5.47..90649.19 rows=16244 width=17)
                    Hash Cond: (mi.info_type_id = it.id)
                    ->  Nested Loop  (cost=1.93..90601.40 rows=16244 width=21)
                          ->  Nested Loop  (cost=1.49..61881.05 rows=12993 width=25)
                                ->  Hash Join  (cost=1.06..35505.92 rows=18858 width=4)
                                      Hash Cond: (mc.company_type_id = ct.id)
                                      ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..35097.06 rows=75431 width=8)
                                            Filter: (((note)::text !~~ '%(TV)%'::text) AND ((note)::text ~~ '%(USA)%'::text))
                                      ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'production companies'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..1.40 rows=1 width=21)
                                      Index Cond: (id = mc.movie_id)
                                      Filter: (production_year > 1990)
                          ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..2.19 rows=2 width=8)
                                Index Cond: (movie_id = t.id)
                                Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Denish,Norwegian,German,USA,American}'::text[]))
                    ->  Hash  (cost=2.13..2.13 rows=113 width=4)
                          ->  Seq Scan on info_type it  (cost=0.00..2.13 rows=113 width=4)
