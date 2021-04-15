SELECT MIN(t.title) AS typical_european_movie
FROM company_type AS ct,
     info_type AS it,
     movie_companies AS mc,
     movie_info AS mi,
     title AS t
WHERE ct.kind = 'production companies'
  AND mc.note LIKE '%(theatrical)%'
  AND mc.note LIKE '%(France)%'
  AND mi.info IN ('Sweden',
                  'Norway',
                  'Germany',
                  'Denmark',
                  'Swedish',
                  'Denish',
                  'Norwegian',
                  'German')
  AND t.production_year > 2005
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND mc.movie_id = mi.movie_id
  AND ct.id = mc.company_type_id
  AND it.id = mi.info_type_id;



Finalize Aggregate  (cost=39390.68..39390.69 rows=1 width=32)
  ->  Gather  (cost=39390.47..39390.68 rows=2 width=32)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=38390.47..38390.48 rows=1 width=32)
              ->  Hash Join  (cost=5.47..38390.37 rows=40 width=17)
                    Hash Cond: (mi.info_type_id = it.id)
                    ->  Nested Loop  (cost=1.93..38386.72 rows=40 width=21)
                          ->  Nested Loop  (cost=1.49..38006.89 rows=156 width=25)
                                ->  Hash Join  (cost=1.06..35106.60 rows=392 width=4)
                                      Hash Cond: (mc.company_type_id = ct.id)
                                      ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..35097.06 rows=1568 width=8)
                                            Filter: (((note)::text ~~ '%(theatrical)%'::text) AND ((note)::text ~~ '%(France)%'::text))
                                      ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                            ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                                  Filter: ((kind)::text = 'production companies'::text)
                                ->  Index Scan using title_pkey on title t  (cost=0.43..7.40 rows=1 width=21)
                                      Index Cond: (id = mc.movie_id)
                                      Filter: (production_year > 2005)
                          ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..2.42 rows=1 width=8)
                                Index Cond: (movie_id = t.id)
                                Filter: ((info)::text = ANY ('{Sweden,Norway,Germany,Denmark,Swedish,Denish,Norwegian,German}'::text[]))
                    ->  Hash  (cost=2.13..2.13 rows=113 width=4)
                          ->  Seq Scan on info_type it  (cost=0.00..2.13 rows=113 width=4)
