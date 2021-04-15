SELECT MIN(an.name) AS acress_pseudonym,
       MIN(t.title) AS japanese_anime_movie
FROM aka_name AS an,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note = '(voice: English version)'
  AND cn.country_code = '[jp]'
  AND mc.note LIKE '%(Japan)%'
  AND mc.note NOT LIKE '%(USA)%'
  AND (mc.note LIKE '%(2006)%'
       OR mc.note LIKE '%(2007)%')
  AND n.name LIKE '%Yo%'
  AND n.name NOT LIKE '%Yu%'
  AND rt.role = 'actress'
  AND t.production_year BETWEEN 2006 AND 2007
  AND (t.title LIKE 'One Piece%'
       OR t.title LIKE 'Dragon Ball Z%')
  AND an.person_id = n.id
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND an.person_id = ci.person_id
  AND ci.movie_id = mc.movie_id;



Aggregate  (cost=42825.84..42825.85 rows=1 width=64)
  ->  Nested Loop  (cost=1002.40..42825.83 rows=1 width=33)
        ->  Nested Loop  (cost=1002.27..42825.66 rows=1 width=37)
              ->  Nested Loop  (cost=1001.84..42824.91 rows=1 width=45)
                    ->  Nested Loop  (cost=1001.42..42823.83 rows=1 width=25)
                          Join Filter: (t.id = ci.movie_id)
                          ->  Gather  (cost=1000.85..42670.49 rows=1 width=25)
                                Workers Planned: 2
                                ->  Nested Loop  (cost=0.85..41670.39 rows=1 width=25)
                                      ->  Nested Loop  (cost=0.42..41636.63 rows=4 width=4)
                                            ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..40532.74 rows=150 width=8)
                                                  Filter: (((note)::text ~~ '%(Japan)%'::text) AND ((note)::text !~~ '%(USA)%'::text) AND (((note)::text ~~ '%(2006)%'::text) OR ((note)::text ~~ '%(2007)%'::text)))
                                            ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..7.36 rows=1 width=4)
                                                  Index Cond: (id = mc.company_id)
                                                  Filter: ((country_code)::text = '[jp]'::text)
                                      ->  Index Scan using title_pkey on title t  (cost=0.43..8.35 rows=1 width=21)
                                            Index Cond: (id = mc.movie_id)
                                            Filter: ((production_year >= 2006) AND (production_year <= 2007) AND (((title)::text ~~ 'One Piece%'::text) OR ((title)::text ~~ 'Dragon Ball Z%'::text)))
                          ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..153.33 rows=1 width=12)
                                Index Cond: (movie_id = mc.movie_id)
                                Filter: ((note)::text = '(voice: English version)'::text)
                    ->  Index Scan using person_id_aka_name on aka_name an  (cost=0.42..1.06 rows=2 width=20)
                          Index Cond: (person_id = ci.person_id)
              ->  Index Scan using name_pkey on name n  (cost=0.43..0.75 rows=1 width=4)
                    Index Cond: (id = an.person_id)
                    Filter: (((name)::text ~~ '%Yo%'::text) AND ((name)::text !~~ '%Yu%'::text))
        ->  Index Scan using role_type_pkey on role_type rt  (cost=0.14..0.16 rows=1 width=4)
              Index Cond: (id = ci.role_id)
              Filter: ((role)::text = 'actress'::text)
