SELECT MIN(n.name) AS member_in_charnamed_movie
FROM cast_info AS ci,
     company_name AS cn,
     keyword AS k,
     movie_companies AS mc,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE k.keyword = 'character-name-in-title'
  AND n.name LIKE '%B%'
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.movie_id = mc.movie_id
  AND ci.movie_id = mk.movie_id
  AND mc.movie_id = mk.movie_id;


Aggregate  (cost=4703.63..4703.64 rows=1 width=32)
  ->  Nested Loop  (cost=9.06..4702.55 rows=431 width=15)
        ->  Nested Loop  (cost=8.64..4511.58 rows=431 width=19)
              ->  Nested Loop  (cost=8.21..4422.61 rows=156 width=27)
                    ->  Nested Loop  (cost=7.78..3832.10 rows=1291 width=16)
                          Join Filter: (t.id = ci.movie_id)
                          ->  Nested Loop  (cost=7.21..3763.55 rows=34 width=8)
                                ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=4)
                                      ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=4)
                                            Filter: ((keyword)::text = 'character-name-in-title'::text)
                                      ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                            Recheck Cond: (keyword_id = k.id)
                                            ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                  Index Cond: (keyword_id = k.id)
                                ->  Index Only Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=4)
                                      Index Cond: (id = mk.movie_id)
                          ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=8)
                                Index Cond: (movie_id = mk.movie_id)
                    ->  Index Scan using name_pkey on name n  (cost=0.43..0.46 rows=1 width=19)
                          Index Cond: (id = ci.person_id)
                          Filter: ((name)::text ~~ '%B%'::text)
              ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.52 rows=5 width=8)
                    Index Cond: (movie_id = ci.movie_id)
        ->  Index Only Scan using company_name_pkey on company_name cn  (cost=0.42..0.44 rows=1 width=4)
              Index Cond: (id = mc.company_id)
