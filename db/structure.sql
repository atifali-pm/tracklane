SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_events (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    actor_id bigint,
    action character varying NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.activity_events FORCE ROW LEVEL SECURITY;


--
-- Name: activity_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_events_id_seq OWNED BY public.activity_events.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    body text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.comments FORCE ROW LEVEL SECURITY;


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    invited_by_id bigint NOT NULL,
    email character varying NOT NULL,
    role integer DEFAULT 2 NOT NULL,
    token character varying NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    accepted_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.invitations FORCE ROW LEVEL SECURITY;


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invitations_id_seq OWNED BY public.invitations.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issues (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    reporter_id bigint NOT NULL,
    assignee_id bigint,
    number integer NOT NULL,
    title character varying NOT NULL,
    description text,
    status integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 1 NOT NULL,
    due_date date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.issues FORCE ROW LEVEL SECURITY;


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.issues_id_seq OWNED BY public.issues.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.memberships (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    role integer DEFAULT 2 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.memberships FORCE ROW LEVEL SECURITY;


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mentions (
    id bigint NOT NULL,
    comment_id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

ALTER TABLE ONLY public.mentions FORCE ROW LEVEL SECURITY;


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mentions_id_seq OWNED BY public.mentions.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    description text,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    issues_counter integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY public.projects FORCE ROW LEVEL SECURITY;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email_address character varying NOT NULL,
    password_digest character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    theme character varying DEFAULT 'system'::character varying NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: activity_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_events ALTER COLUMN id SET DEFAULT nextval('public.activity_events_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations ALTER COLUMN id SET DEFAULT nextval('public.invitations_id_seq'::regclass);


--
-- Name: issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: mentions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions ALTER COLUMN id SET DEFAULT nextval('public.mentions_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: activity_events activity_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_events
    ADD CONSTRAINT activity_events_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: mentions mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_activity_events_on_actor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_events_on_actor_id ON public.activity_events USING btree (actor_id);


--
-- Name: index_activity_events_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_events_on_organization_id ON public.activity_events USING btree (organization_id);


--
-- Name: index_activity_events_on_organization_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_events_on_organization_id_and_created_at ON public.activity_events USING btree (organization_id, created_at);


--
-- Name: index_activity_events_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_events_on_subject_type_and_subject_id ON public.activity_events USING btree (subject_type, subject_id);


--
-- Name: index_comments_on_issue_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_issue_id ON public.comments USING btree (issue_id);


--
-- Name: index_comments_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_organization_id ON public.comments USING btree (organization_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_user_id ON public.comments USING btree (user_id);


--
-- Name: index_invitations_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_invited_by_id ON public.invitations USING btree (invited_by_id);


--
-- Name: index_invitations_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_invitations_on_organization_id ON public.invitations USING btree (organization_id);


--
-- Name: index_invitations_on_organization_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invitations_on_organization_id_and_email ON public.invitations USING btree (organization_id, email) WHERE (accepted_at IS NULL);


--
-- Name: index_invitations_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_invitations_on_token ON public.invitations USING btree (token);


--
-- Name: index_issues_on_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_assignee_id ON public.issues USING btree (assignee_id);


--
-- Name: index_issues_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_organization_id ON public.issues USING btree (organization_id);


--
-- Name: index_issues_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_priority ON public.issues USING btree (priority);


--
-- Name: index_issues_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_project_id ON public.issues USING btree (project_id);


--
-- Name: index_issues_on_project_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issues_on_project_id_and_number ON public.issues USING btree (project_id, number);


--
-- Name: index_issues_on_reporter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_reporter_id ON public.issues USING btree (reporter_id);


--
-- Name: index_issues_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_status ON public.issues USING btree (status);


--
-- Name: index_memberships_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_organization_id ON public.memberships USING btree (organization_id);


--
-- Name: index_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_user_id ON public.memberships USING btree (user_id);


--
-- Name: index_memberships_on_user_id_and_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_memberships_on_user_id_and_organization_id ON public.memberships USING btree (user_id, organization_id);


--
-- Name: index_mentions_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mentions_on_comment_id ON public.mentions USING btree (comment_id);


--
-- Name: index_mentions_on_comment_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mentions_on_comment_id_and_user_id ON public.mentions USING btree (comment_id, user_id);


--
-- Name: index_mentions_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mentions_on_organization_id ON public.mentions USING btree (organization_id);


--
-- Name: index_mentions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mentions_on_user_id ON public.mentions USING btree (user_id);


--
-- Name: index_organizations_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_slug ON public.organizations USING btree (slug);


--
-- Name: index_projects_on_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_organization_id ON public.projects USING btree (organization_id);


--
-- Name: index_projects_on_organization_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_organization_id_and_slug ON public.projects USING btree (organization_id, slug);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address);


--
-- Name: comments fk_rails_03de2dc08c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_03de2dc08c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: invitations fk_rails_0fe4c14f0e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT fk_rails_0fe4c14f0e FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: mentions fk_rails_1b711e94aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_1b711e94aa FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: mentions fk_rails_317de4030a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_317de4030a FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: mentions fk_rails_466352825b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT fk_rails_466352825b FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: activity_events fk_rails_4a058a76d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_events
    ADD CONSTRAINT fk_rails_4a058a76d2 FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: memberships fk_rails_64267aab58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_64267aab58 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sessions fk_rails_758836b4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT fk_rails_758836b4f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: issues fk_rails_899c8f3231; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_rails_899c8f3231 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: comments fk_rails_90ef1875d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_90ef1875d1 FOREIGN KEY (issue_id) REFERENCES public.issues(id);


--
-- Name: memberships fk_rails_99326fb65d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT fk_rails_99326fb65d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: projects fk_rails_9aee26923d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_9aee26923d FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: comments fk_rails_b5b64d6bc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_b5b64d6bc9 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: issues fk_rails_ccc5514bad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_rails_ccc5514bad FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: invitations fk_rails_d799c974a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT fk_rails_d799c974a1 FOREIGN KEY (invited_by_id) REFERENCES public.users(id);


--
-- Name: issues fk_rails_e760f5afbf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_rails_e760f5afbf FOREIGN KEY (reporter_id) REFERENCES public.users(id);


--
-- Name: activity_events fk_rails_f48aed71c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_events
    ADD CONSTRAINT fk_rails_f48aed71c3 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: issues fk_rails_ff669b5916; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT fk_rails_ff669b5916 FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- Name: activity_events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.activity_events ENABLE ROW LEVEL SECURITY;

--
-- Name: comments; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

--
-- Name: invitations; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.invitations ENABLE ROW LEVEL SECURITY;

--
-- Name: invitations invitations_select_by_token; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY invitations_select_by_token ON public.invitations FOR SELECT USING (true);


--
-- Name: issues; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.issues ENABLE ROW LEVEL SECURITY;

--
-- Name: memberships; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: memberships memberships_select_own_or_tenant; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY memberships_select_own_or_tenant ON public.memberships FOR SELECT USING (((user_id = (NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::bigint) OR (organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)));


--
-- Name: memberships memberships_write_tenant; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY memberships_write_tenant ON public.memberships USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- Name: mentions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.mentions ENABLE ROW LEVEL SECURITY;

--
-- Name: projects; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

--
-- Name: activity_events tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.activity_events USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- Name: comments tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.comments USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- Name: invitations tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.invitations USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- Name: issues tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.issues USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- Name: mentions tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.mentions USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- Name: projects tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.projects USING ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint)) WITH CHECK ((organization_id = (NULLIF(current_setting('app.current_organization_id'::text, true), ''::text))::bigint));


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260423080634'),
('20260422180251'),
('20260422174703'),
('20260422174159'),
('20260422172302'),
('20260422171633'),
('20260422170439'),
('20260422163957'),
('20260422131515'),
('20260422131514'),
('20260422131430'),
('20260422131420'),
('20260422131252'),
('20260422131250');

