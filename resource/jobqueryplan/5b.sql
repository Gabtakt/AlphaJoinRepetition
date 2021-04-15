SELECT MIN(t.title) AS american_vhs_movie
FROM company_type AS ct,
     info_type AS it,
     movie_companies AS mc,
     movie_info AS mi,
     title AS t
WHERE ct.kind = 'production companies'
  AND mc.note LIKE '%(VHS)%'
  AND mc.note LIKE '%(USA)%'
  AND mc.note LIKE '%(1994)%'
  AND mi.info IN ('USA',
                  'America')
  AND t.production_year > 2010
  AND t.id = mi.movie_id
  AND t.id = mc.movie_id
  AND mc.movie_id = mi.movie_id
  AND ct.id = mc.company_type_id
  AND it.id = mi.info_type_id;



Aggregate  (cost=38870.51..38870.52 rows=1 width=32)
  ->  Gather  (cost=1002.07..38870.51 rows=2 width=17)
        Workers Planned: 2
        ->  Nested Loop  (cost=2.07..37870.31 rows=1 width=17)
              ->  Nested Loop  (cost=1.93..37870.15 rows=1 width=21)
                    ->  Nested Loop  (cost=1.49..37866.79 rows=1 width=25)
                          ->  Hash Join  (cost=1.06..37816.09 rows=6 width=4)
                                Hash Cond: (mc.company_type_id = ct.id)
                                ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..37814.90 rows=24 width=8)
                                      Filter: (((note)::text ~~ '%(VHS)%'::text) AND ((note)::text ~~ '%(USA)%'::text) AND ((note)::text ~~ '%(1994)%'::text))
                                ->  Hash  (cost=1.05..1.05 rows=1 width=4)
                                      ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=1 width=4)
                                            Filter: ((kind)::text = 'production companies'::text)
                          ->  Index Scan using title_pkey on title t  (cost=0.43..8.45 rows=1 width=21)
                                Index Cond: (id = mc.movie_id)
                                Filter: (production_year > 2010)
                    ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..3.35 rows=1 width=8)
                          Index Cond: (movie_id = t.id)
                          Filter: ((info)::text = ANY ('{USA,America}'::text[]))
              ->  Index Only Scan using info_type_pkey on info_type it  (cost=0.14..0.16 rows=1 width=4)
                    Index Cond: (id = mi.info_type_id)
