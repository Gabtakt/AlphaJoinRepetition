SELECT MIN(cn.name) AS from_company,
       MIN(mc.note) AS production_note,
       MIN(t.title) AS movie_based_on_book
FROM company_name AS cn,
     company_type AS ct,
     keyword AS k,
     link_type AS lt,
     movie_companies AS mc,
     movie_keyword AS mk,
     movie_link AS ml,
     title AS t
WHERE cn.country_code != '[pl]'
  AND (cn.name LIKE '20th Century Fox%'
       OR cn.name LIKE 'Twentieth Century Fox%')
  AND ct.kind != 'production companies'
  AND ct.kind IS NOT NULL
  AND k.keyword IN ('sequel',
                    'revenge',
                    'based-on-novel')
  AND mc.note IS NOT NULL
  AND t.production_year > 1950
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id;



Aggregate  (cost=6206.80..6206.81 rows=1 width=96)
  ->  Nested Loop  (cost=8.35..6206.79 rows=1 width=60)
        Join Filter: (ml.movie_id = t.id)
        ->  Nested Loop  (cost=7.92..6206.29 rows=1 width=55)
              Join Filter: (ml.link_type_id = lt.id)
              ->  Nested Loop  (cost=7.92..6204.89 rows=1 width=59)
                    ->  Nested Loop  (cost=7.50..6178.90 rows=57 width=44)
                          Join Filter: (mc.company_type_id = ct.id)
                          ->  Nested Loop  (cost=7.50..6174.85 rows=76 width=48)
                                Join Filter: (ml.movie_id = mc.movie_id)
                                ->  Nested Loop  (cost=7.07..6157.51 rows=30 width=12)
                                      ->  Nested Loop  (cost=6.78..6114.56 rows=101 width=4)
                                            ->  Seq Scan on keyword k  (cost=0.00..2793.84 rows=3 width=4)
                                                  Filter: ((keyword)::text = ANY ('{sequel,revenge,based-on-novel}'::text[]))
                                            ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1103.88 rows=303 width=8)
                                                  Recheck Cond: (keyword_id = k.id)
                                                  ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                        Index Cond: (keyword_id = k.id)
                                      ->  Index Scan using movie_id_movie_link on movie_link ml  (cost=0.29..0.38 rows=5 width=8)
                                            Index Cond: (movie_id = mk.movie_id)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=3 width=36)
                                      Index Cond: (movie_id = mk.movie_id)
                                      Filter: (note IS NOT NULL)
                          ->  Materialize  (cost=0.00..1.06 rows=3 width=4)
                                ->  Seq Scan on company_type ct  (cost=0.00..1.05 rows=3 width=4)
                                      Filter: ((kind IS NOT NULL) AND ((kind)::text <> 'production companies'::text))
                    ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.46 rows=1 width=23)
                          Index Cond: (id = mc.company_id)
                          Filter: (((country_code)::text <> '[pl]'::text) AND (((name)::text ~~ '20th Century Fox%'::text) OR ((name)::text ~~ 'Twentieth Century Fox%'::text)))
              ->  Seq Scan on link_type lt  (cost=0.00..1.18 rows=18 width=4)
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
              Index Cond: (id = mk.movie_id)
              Filter: (production_year > 1950)
