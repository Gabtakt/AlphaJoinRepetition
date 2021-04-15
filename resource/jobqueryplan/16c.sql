SELECT MIN(an.name) AS cool_actor_pseudonym,
       MIN(t.title) AS series_named_after_char
FROM aka_name AS an,
     cast_info AS ci,
     company_name AS cn,
     keyword AS k,
     movie_companies AS mc,
     movie_keyword AS mk,
     name AS n,
     title AS t
WHERE cn.country_code = '[us]'
  AND k.keyword = 'character-name-in-title'
  AND t.episode_nr < 100
  AND an.person_id = n.id
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND an.person_id = ci.person_id
  AND ci.movie_id = mc.movie_id
  AND ci.movie_id = mk.movie_id
  AND mc.movie_id = mk.movie_id;



Aggregate  (cost=4311.46..4311.47 rows=1 width=64)
  ->  Nested Loop  (cost=9.48..4305.78 rows=1135 width=33)
        Join Filter: (n.id = an.person_id)
        ->  Nested Loop  (cost=9.06..4068.35 rows=488 width=25)
              ->  Nested Loop  (cost=8.63..3846.36 rows=488 width=21)
                    Join Filter: (t.id = ci.movie_id)
                    ->  Nested Loop  (cost=8.06..3799.99 rows=23 width=29)
                          ->  Nested Loop  (cost=7.64..3771.47 rows=64 width=33)
                                Join Filter: (t.id = mc.movie_id)
                                ->  Nested Loop  (cost=7.21..3763.63 rows=13 width=25)
                                      ->  Nested Loop  (cost=6.78..3747.04 rows=34 width=4)
                                            ->  Seq Scan on keyword k  (cost=0.00..2626.12 rows=1 width=4)
                                                  Filter: ((keyword)::text = 'character-name-in-title'::text)
                                            ->  Bitmap Heap Scan on movie_keyword mk  (cost=6.78..1117.89 rows=303 width=8)
                                                  Recheck Cond: (keyword_id = k.id)
                                                  ->  Bitmap Index Scan on keyword_id_movie_keyword  (cost=0.00..6.71 rows=303 width=0)
                                                        Index Cond: (keyword_id = k.id)
                                      ->  Index Scan using title_pkey on title t  (cost=0.43..0.49 rows=1 width=21)
                                            Index Cond: (id = mk.movie_id)
                                            Filter: (episode_nr < 100)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.54 rows=5 width=8)
                                      Index Cond: (movie_id = mk.movie_id)
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text = '[us]'::text)
                    ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..1.54 rows=38 width=8)
                          Index Cond: (movie_id = mk.movie_id)
              ->  Index Only Scan using name_pkey on name n  (cost=0.43..0.45 rows=1 width=4)
                    Index Cond: (id = ci.person_id)
        ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..0.46 rows=2 width=20)
              Index Cond: (person_id = ci.person_id)
