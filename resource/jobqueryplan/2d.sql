SELECT MIN(t.title) AS movie_title
FROM company_name AS cn,
     keyword AS k,
     movie_companies AS mc,
     movie_keyword AS mk,
     title AS t
WHERE cn.country_code = '[us]'
  AND k.keyword = 'character-name-in-title'
  AND cn.id = mc.company_id
  AND mc.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND mc.movie_id = mk.movie_id;



Aggregate  (cost=3859.50..3859.51 rows=1 width=32)
  ->  Nested Loop  (cost=8.06..3859.35 rows=61 width=17)
        ->  Nested Loop  (cost=7.64..3784.05 rows=169 width=21)
              Join Filter: (t.id = mc.movie_id)
              ->  Nested Loop  (cost=7.21..3763.55 rows=34 width=25)
                    ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=4)
                          ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=4)
                                Filter: ((keyword)::text = 'character-name-in-title'::text)
                          ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                Recheck Cond: (keyword_id = k.id)
                                ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                      Index Cond: (keyword_id = k.id)
                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
                          Index Cond: (id = mk.movie_id)
              ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=5 width=8)
                    Index Cond: (movie_id = mk.movie_id)
        ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
              Index Cond: (id = mc.company_id)
              Filter: ((country_code)::text = '[us]'::text)
