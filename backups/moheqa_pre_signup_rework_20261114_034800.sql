--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.announcements (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    body text,
    category character varying NOT NULL,
    audience character varying NOT NULL,
    scheme_id integer,
    pinned boolean DEFAULT false NOT NULL,
    publish_from date,
    publish_until date,
    event_at timestamp with time zone,
    event_ends_at timestamp with time zone,
    location character varying,
    link_url character varying,
    published_at timestamp with time zone,
    published_by character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    CONSTRAINT ck_announcements_audience_scheme CHECK (((((audience)::text = 'Scheme'::text) AND (scheme_id IS NOT NULL)) OR (((audience)::text <> 'Scheme'::text) AND (scheme_id IS NULL)))),
    CONSTRAINT ck_announcements_event_window CHECK (((event_at IS NULL) OR (event_ends_at IS NULL) OR (event_ends_at >= event_at))),
    CONSTRAINT ck_announcements_window CHECK (((publish_from IS NULL) OR (publish_until IS NULL) OR (publish_until >= publish_from)))
);


ALTER TABLE public.announcements OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.announcements_id_seq OWNER TO postgres;

--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    lab_id integer NOT NULL,
    scheme_id integer NOT NULL,
    service_id integer NOT NULL,
    method_id integer NOT NULL,
    user_id integer,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.applications OWNER TO postgres;

--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.applications_id_seq OWNER TO postgres;

--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attachments (
    id integer NOT NULL,
    name character varying,
    path character varying,
    filesize integer,
    filetype character varying,
    parent integer,
    type character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.attachments OWNER TO postgres;

--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attachments_id_seq OWNER TO postgres;

--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: audits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audits (
    id integer NOT NULL,
    user_id integer NOT NULL,
    user_email character varying NOT NULL,
    token character varying NOT NULL,
    date timestamp with time zone NOT NULL,
    feature character varying NOT NULL,
    model character varying,
    object_id integer,
    action character varying NOT NULL,
    before jsonb,
    after jsonb,
    created_at timestamp with time zone,
    created_by character varying
);


ALTER TABLE public.audits OWNER TO postgres;

--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audits_id_seq OWNER TO postgres;

--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: bacteriology_ast_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bacteriology_ast_results (
    id integer NOT NULL,
    bacteriology_result_id integer NOT NULL,
    ast_method character varying NOT NULL,
    row_no integer NOT NULL,
    antibiotic character varying NOT NULL,
    zone_diameter double precision,
    mic_reading character varying,
    interpretation character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.bacteriology_ast_results OWNER TO postgres;

--
-- Name: bacteriology_ast_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bacteriology_ast_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bacteriology_ast_results_id_seq OWNER TO postgres;

--
-- Name: bacteriology_ast_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bacteriology_ast_results_id_seq OWNED BY public.bacteriology_ast_results.id;


--
-- Name: bacteriology_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bacteriology_results (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    date_samples_received date,
    receipt_temperature double precision,
    sample_condition character varying,
    sample_condition_reason character varying,
    date_submitted date,
    testing_not_done boolean NOT NULL,
    testing_not_done_reason character varying,
    gram_stain_reaction character varying,
    gram_morphology character varying,
    gram_morphology_other character varying,
    microscopy_comment character varying,
    organism_identified character varying,
    identification_comment character varying,
    ast_performed boolean NOT NULL,
    ast_guideline character varying,
    ast_disk_diffusion boolean NOT NULL,
    ast_mic_method character varying,
    ast_mic_method_other character varying,
    comments character varying,
    reported_by character varying,
    reported_on date,
    reviewed_by character varying,
    reviewed_on date,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.bacteriology_results OWNER TO postgres;

--
-- Name: bacteriology_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bacteriology_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bacteriology_results_id_seq OWNER TO postgres;

--
-- Name: bacteriology_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bacteriology_results_id_seq OWNED BY public.bacteriology_results.id;


--
-- Name: districts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.districts (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    province_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.districts OWNER TO postgres;

--
-- Name: districts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.districts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.districts_id_seq OWNER TO postgres;

--
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.districts_id_seq OWNED BY public.districts.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollments (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    method_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    samples_received_at timestamp with time zone,
    samples_received_by character varying
);


ALTER TABLE public.enrollments OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enrollments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enrollments_id_seq OWNER TO postgres;

--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: hiv_eid_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hiv_eid_results (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    date_panel_received date,
    date_tested date,
    detection_assay character varying,
    extraction_assay character varying,
    assay_serial_number character varying,
    result_reported character varying,
    hiv_result character varying,
    hiv_ct_od_value double precision,
    ic_qs_value double precision,
    not_tested_reason character varying,
    tested_by character varying,
    supervisor_name character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.hiv_eid_results OWNER TO postgres;

--
-- Name: hiv_eid_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hiv_eid_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hiv_eid_results_id_seq OWNER TO postgres;

--
-- Name: hiv_eid_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hiv_eid_results_id_seq OWNED BY public.hiv_eid_results.id;


--
-- Name: hiv_vl_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hiv_vl_results (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    date_panel_received date,
    date_tested date,
    detection_assay character varying,
    extraction_assay character varying,
    assay_kit_lot_number character varying,
    assay_kit_expiry_date date,
    assay_serial_number character varying,
    result_reported character varying,
    viral_load_log10 double precision,
    not_tested_reason character varying,
    tested_by character varying,
    supervisor_name character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.hiv_vl_results OWNER TO postgres;

--
-- Name: hiv_vl_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hiv_vl_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hiv_vl_results_id_seq OWNER TO postgres;

--
-- Name: hiv_vl_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hiv_vl_results_id_seq OWNED BY public.hiv_vl_results.id;


--
-- Name: lab_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lab_types (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.lab_types OWNER TO postgres;

--
-- Name: lab_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lab_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.lab_types_id_seq OWNER TO postgres;

--
-- Name: lab_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lab_types_id_seq OWNED BY public.lab_types.id;


--
-- Name: laboratorys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.laboratorys (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    contact_person_name character varying NOT NULL,
    code character varying NOT NULL,
    lab_type_id integer NOT NULL,
    "position" character varying NOT NULL,
    district_id integer NOT NULL,
    province_id integer NOT NULL,
    phone_number character varying NOT NULL,
    physical_address character varying NOT NULL,
    email_address character varying NOT NULL,
    user_id integer,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    method_list jsonb
);


ALTER TABLE public.laboratorys OWNER TO postgres;

--
-- Name: laboratorys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.laboratorys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.laboratorys_id_seq OWNER TO postgres;

--
-- Name: laboratorys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.laboratorys_id_seq OWNED BY public.laboratorys.id;


--
-- Name: list_stages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_stages (
    id integer NOT NULL,
    stage_name character varying NOT NULL,
    description character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.list_stages OWNER TO postgres;

--
-- Name: list_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.list_stages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.list_stages_id_seq OWNER TO postgres;

--
-- Name: list_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.list_stages_id_seq OWNED BY public.list_stages.id;


--
-- Name: list_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.list_statuses (
    id integer NOT NULL,
    status_name character varying NOT NULL,
    description character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.list_statuses OWNER TO postgres;

--
-- Name: list_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.list_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.list_statuses_id_seq OWNER TO postgres;

--
-- Name: list_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.list_statuses_id_seq OWNED BY public.list_statuses.id;


--
-- Name: meters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meters (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    customer_number character varying NOT NULL,
    customer_name character varying NOT NULL,
    identity_number character varying NOT NULL,
    address character varying NOT NULL,
    communicate_address character varying NOT NULL,
    invoice_number character varying NOT NULL,
    open_account_date date NOT NULL,
    station_name character varying NOT NULL,
    operator_uid character varying NOT NULL,
    province_name character varying NOT NULL,
    city_name character varying NOT NULL,
    town_name character varying NOT NULL,
    village_name character varying NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.meters OWNER TO postgres;

--
-- Name: meters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.meters_id_seq OWNER TO postgres;

--
-- Name: meters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meters_id_seq OWNED BY public.meters.id;


--
-- Name: method_sample_expected_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.method_sample_expected_values (
    id integer NOT NULL,
    method_sample_id integer NOT NULL,
    attribute character varying NOT NULL,
    expected_value_numeric double precision,
    expected_value_text character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.method_sample_expected_values OWNER TO postgres;

--
-- Name: method_sample_expected_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.method_sample_expected_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.method_sample_expected_values_id_seq OWNER TO postgres;

--
-- Name: method_sample_expected_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.method_sample_expected_values_id_seq OWNED BY public.method_sample_expected_values.id;


--
-- Name: method_samples; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.method_samples (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    method_id integer NOT NULL,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    assigned_value_source character varying,
    is_control boolean DEFAULT false NOT NULL
);


ALTER TABLE public.method_samples OWNER TO postgres;

--
-- Name: method_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.method_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.method_samples_id_seq OWNER TO postgres;

--
-- Name: method_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.method_samples_id_seq OWNED BY public.method_samples.id;


--
-- Name: methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.methods (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    result_form character varying
);


ALTER TABLE public.methods OWNER TO postgres;

--
-- Name: methods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.methods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.methods_id_seq OWNER TO postgres;

--
-- Name: methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.methods_id_seq OWNED BY public.methods.id;


--
-- Name: providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.providers (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.providers OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.providers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.providers_id_seq OWNER TO postgres;

--
-- Name: providers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.providers_id_seq OWNED BY public.providers.id;


--
-- Name: provinces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provinces (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    code character varying NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.provinces OWNER TO postgres;

--
-- Name: provinces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.provinces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.provinces_id_seq OWNER TO postgres;

--
-- Name: provinces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.provinces_id_seq OWNED BY public.provinces.id;


--
-- Name: pt_cycle_samples; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_cycle_samples (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_cycle_samples OWNER TO postgres;

--
-- Name: pt_cycle_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_cycle_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_cycle_samples_id_seq OWNER TO postgres;

--
-- Name: pt_cycle_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_cycle_samples_id_seq OWNED BY public.pt_cycle_samples.id;


--
-- Name: pt_cycle_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_cycle_statuses (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_cycle_statuses OWNER TO postgres;

--
-- Name: pt_cycle_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_cycle_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_cycle_statuses_id_seq OWNER TO postgres;

--
-- Name: pt_cycle_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_cycle_statuses_id_seq OWNED BY public.pt_cycle_statuses.id;


--
-- Name: pt_cycles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_cycles (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    code character varying NOT NULL,
    effective_date date NOT NULL,
    scheme_id integer NOT NULL,
    pt_cyle_status_id integer NOT NULL,
    closing_date date NOT NULL,
    shipping_date date NOT NULL,
    reports_availability_date date NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_cycles OWNER TO postgres;

--
-- Name: pt_cycles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_cycles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_cycles_id_seq OWNER TO postgres;

--
-- Name: pt_cycles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_cycles_id_seq OWNED BY public.pt_cycles.id;


--
-- Name: pt_enrollment_performance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_enrollment_performance (
    id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    lab_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    method_id integer NOT NULL,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    result_form character varying NOT NULL,
    report_number character varying,
    attributes_total integer NOT NULL,
    attributes_evaluated integer NOT NULL,
    acceptable_count integer NOT NULL,
    warning_count integer NOT NULL,
    unacceptable_count integer NOT NULL,
    not_reported_count integer NOT NULL,
    total_score integer NOT NULL,
    max_score integer NOT NULL,
    percent_score double precision,
    overall_performance character varying NOT NULL,
    reason_for_no_evaluation character varying,
    frozen_at timestamp with time zone,
    frozen_by character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_enrollment_performance OWNER TO postgres;

--
-- Name: pt_enrollment_performance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_enrollment_performance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_enrollment_performance_id_seq OWNER TO postgres;

--
-- Name: pt_enrollment_performance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_enrollment_performance_id_seq OWNED BY public.pt_enrollment_performance.id;


--
-- Name: pt_result_evaluations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_result_evaluations (
    id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    lab_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    method_id integer NOT NULL,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    result_form character varying NOT NULL,
    result_id integer NOT NULL,
    attribute character varying NOT NULL,
    attribute_label character varying,
    reported_numeric double precision,
    reported_text character varying,
    assigned_numeric double precision,
    assigned_text character varying,
    group_mean double precision,
    robust_sd double precision,
    deviation double precision,
    z_score double precision,
    score integer NOT NULL,
    max_score integer NOT NULL,
    grade character varying NOT NULL,
    evaluated boolean NOT NULL,
    not_evaluated_reason character varying,
    frozen_at timestamp with time zone,
    frozen_by character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.pt_result_evaluations OWNER TO postgres;

--
-- Name: pt_result_evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_result_evaluations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_result_evaluations_id_seq OWNER TO postgres;

--
-- Name: pt_result_evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_result_evaluations_id_seq OWNED BY public.pt_result_evaluations.id;


--
-- Name: pt_sample_statistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pt_sample_statistics (
    id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    method_id integer NOT NULL,
    service_id integer NOT NULL,
    scheme_id integer NOT NULL,
    result_form character varying NOT NULL,
    attribute character varying NOT NULL,
    attribute_label character varying,
    evaluation_kind character varying NOT NULL,
    assigned_value_numeric double precision,
    assigned_value_text character varying,
    assigned_value_source character varying,
    participant_count integer NOT NULL,
    reported_count integer NOT NULL,
    group_mean double precision,
    group_median double precision,
    robust_sd double precision,
    standard_sd double precision,
    minimum_value double precision,
    maximum_value double precision,
    concordant_count integer,
    evaluated boolean NOT NULL,
    not_evaluated_reason character varying,
    frozen_at timestamp with time zone,
    frozen_by character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    sample_group character varying
);


ALTER TABLE public.pt_sample_statistics OWNER TO postgres;

--
-- Name: pt_sample_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pt_sample_statistics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pt_sample_statistics_id_seq OWNER TO postgres;

--
-- Name: pt_sample_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pt_sample_statistics_id_seq OWNED BY public.pt_sample_statistics.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schemes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schemes (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    provider_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.schemes OWNER TO postgres;

--
-- Name: schemes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schemes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schemes_id_seq OWNER TO postgres;

--
-- Name: schemes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schemes_id_seq OWNED BY public.schemes.id;


--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: services_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.services_id_seq OWNER TO postgres;

--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.services_id_seq OWNED BY public.services.id;


--
-- Name: tb_xpert_ultra_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_xpert_ultra_results (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    result_interpretable character varying,
    tb_detection_result character varying,
    rif_result character varying,
    uninterpretable_result character varying,
    ultra_spc double precision,
    is1081_is6110 double precision,
    rpob1 double precision,
    rpob2 double precision,
    rpob3 double precision,
    rpob4 double precision,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    xpert_module_number character varying,
    date_tested date,
    error_code character varying
);


ALTER TABLE public.tb_xpert_ultra_results OWNER TO postgres;

--
-- Name: tb_xpert_ultra_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_xpert_ultra_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_xpert_ultra_results_id_seq OWNER TO postgres;

--
-- Name: tb_xpert_ultra_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_xpert_ultra_results_id_seq OWNED BY public.tb_xpert_ultra_results.id;


--
-- Name: tb_xpert_xdr_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tb_xpert_xdr_results (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    scheme_id integer NOT NULL,
    lab_id integer NOT NULL,
    service_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    pt_cycle_id integer NOT NULL,
    method_id integer NOT NULL,
    method_sample_id integer NOT NULL,
    date_tested date,
    result_interpretable character varying,
    tb_detection_result character varying,
    inh_result character varying,
    flq_result character varying,
    amk_result character varying,
    eth_result character varying,
    uninterpretable_result character varying,
    error_code character varying,
    spc_ahpc double precision,
    inha double precision,
    katg double precision,
    fabg1 double precision,
    gyra1 double precision,
    gyra2 double precision,
    gyra3 double precision,
    gyrb2 double precision,
    rrs double precision,
    user_id integer NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying
);


ALTER TABLE public.tb_xpert_xdr_results OWNER TO postgres;

--
-- Name: tb_xpert_xdr_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tb_xpert_xdr_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tb_xpert_xdr_results_id_seq OWNER TO postgres;

--
-- Name: tb_xpert_xdr_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tb_xpert_xdr_results_id_seq OWNED BY public.tb_xpert_xdr_results.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    code character varying,
    type integer,
    fname character varying NOT NULL,
    lname character varying NOT NULL,
    "position" character varying,
    email character varying NOT NULL,
    mobile_code character varying NOT NULL,
    mobile character varying NOT NULL,
    address_physical character varying,
    address_postal character varying,
    role_id integer NOT NULL,
    password character varying NOT NULL,
    status_id integer NOT NULL,
    stage_id integer NOT NULL,
    approval_levels integer NOT NULL,
    review1_at timestamp with time zone,
    review1_by character varying,
    review1_comments character varying,
    review2_at timestamp with time zone,
    review2_by character varying,
    review2_comments character varying,
    review3_at timestamp with time zone,
    review3_by character varying,
    review3_comments character varying,
    created_at timestamp with time zone,
    created_by character varying,
    updated_at timestamp with time zone,
    updated_by character varying,
    laboratory_id integer,
    province_id integer,
    district_id integer
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vw_laboratory_scheme; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_laboratory_scheme AS
 SELECT a.lab_id,
    l.code AS lab_code,
    l.name AS lab_name,
    s.id AS scheme_id,
    s.name AS scheme_name,
    p.id AS provider_id,
    p.name AS provider_name,
    count(*) AS method_count,
    count(*) FILTER (WHERE (a.status_id = 4)) AS accepted_count,
    count(*) FILTER (WHERE (a.status_id = ANY (ARRAY[2, 3]))) AS pending_count,
    count(*) FILTER (WHERE (a.status_id = 5)) AS rejected_count,
    string_agg((m.name)::text, ', '::text ORDER BY (m.name)::text) AS method_names,
    string_agg((m.name)::text, ', '::text ORDER BY (m.name)::text) FILTER (WHERE (a.status_id = 4)) AS accepted_method_names,
        CASE
            WHEN (count(*) FILTER (WHERE (a.status_id = 4)) > 0) THEN 'Accepted'::text
            WHEN (count(*) FILTER (WHERE (a.status_id = ANY (ARRAY[2, 3]))) > 0) THEN 'Pending'::text
            ELSE 'Rejected'::text
        END AS participation
   FROM ((((public.applications a
     JOIN public.laboratorys l ON ((l.id = a.lab_id)))
     JOIN public.schemes s ON ((s.id = a.scheme_id)))
     JOIN public.providers p ON ((p.id = s.provider_id)))
     JOIN public.methods m ON ((m.id = a.method_id)))
  GROUP BY a.lab_id, l.code, l.name, s.id, s.name, p.id, p.name;


ALTER VIEW public.vw_laboratory_scheme OWNER TO postgres;

--
-- Name: vw_announcement_audience; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_announcement_audience AS
 SELECT a.id AS announcement_id,
    a.name,
    a.description,
    a.category,
    a.audience,
    a.scheme_id,
    s.name AS scheme_name,
    a.pinned,
    a.publish_from,
    a.publish_until,
    a.event_at,
    a.event_ends_at,
    a.location,
    a.link_url,
    a.published_at,
    a.published_by,
    l.id AS lab_id,
    l.code AS lab_code,
    l.name AS lab_name
   FROM ((public.announcements a
     JOIN public.laboratorys l ON ((((a.audience)::text = 'All Participants'::text) OR (EXISTS ( SELECT 1
           FROM public.vw_laboratory_scheme v
          WHERE ((v.lab_id = l.id) AND (v.scheme_id = a.scheme_id) AND (v.participation = 'Accepted'::text)))))))
     LEFT JOIN public.schemes s ON ((s.id = a.scheme_id)))
  WHERE ((a.status_id = 4) AND ((a.publish_from IS NULL) OR (a.publish_from <= CURRENT_DATE)) AND ((a.publish_until IS NULL) OR (a.publish_until >= CURRENT_DATE)));


ALTER VIEW public.vw_announcement_audience OWNER TO postgres;

--
-- Name: vw_pt_enrollment_performance; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_pt_enrollment_performance AS
 SELECT pf.id AS performance_id,
    pf.report_number,
    pf.pt_cycle_id,
    c.code AS cycle_code,
    c.name AS cycle_name,
    c.effective_date AS shipment_date,
    c.closing_date AS shipment_target_date,
    c.shipping_date,
    c.reports_availability_date AS report_date,
    cs.name AS cycle_status,
    p.id AS provider_id,
    p.name AS provider_name,
    sc.id AS scheme_id,
    sc.name AS scheme_name,
    sv.id AS service_id,
    sv.name AS service_name,
    m.id AS method_id,
    m.name AS method_name,
    pf.result_form,
    pf.lab_id,
    l.code AS lab_code,
    l.name AS lab_name,
    l.contact_person_name,
    l.email_address AS lab_email,
    l.phone_number AS lab_phone,
    l.physical_address,
    lt.name AS lab_type,
    prov.name AS province_name,
    d.name AS district_name,
    pf.enrollment_id,
    en.samples_received_at,
    pf.attributes_total,
    pf.attributes_evaluated,
    pf.acceptable_count,
    pf.warning_count,
    pf.unacceptable_count,
    pf.not_reported_count,
    pf.total_score,
    pf.max_score,
    pf.percent_score,
    round(((pf.percent_score * (100)::double precision))::numeric, 1) AS percent_score_display,
    pf.overall_performance,
    pf.reason_for_no_evaluation,
    pf.frozen_at
   FROM (((((((((((public.pt_enrollment_performance pf
     JOIN public.pt_cycles c ON ((c.id = pf.pt_cycle_id)))
     JOIN public.pt_cycle_statuses cs ON ((cs.id = c.pt_cyle_status_id)))
     JOIN public.schemes sc ON ((sc.id = pf.scheme_id)))
     JOIN public.providers p ON ((p.id = sc.provider_id)))
     JOIN public.services sv ON ((sv.id = pf.service_id)))
     JOIN public.methods m ON ((m.id = pf.method_id)))
     JOIN public.laboratorys l ON ((l.id = pf.lab_id)))
     LEFT JOIN public.lab_types lt ON ((lt.id = l.lab_type_id)))
     LEFT JOIN public.provinces prov ON ((prov.id = l.province_id)))
     LEFT JOIN public.districts d ON ((d.id = l.district_id)))
     JOIN public.enrollments en ON ((en.id = pf.enrollment_id)));


ALTER VIEW public.vw_pt_enrollment_performance OWNER TO postgres;

--
-- Name: vw_pt_result_evaluation; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_pt_result_evaluation AS
 SELECT e.id AS evaluation_id,
    e.pt_cycle_id,
    c.code AS cycle_code,
    c.name AS cycle_name,
    c.effective_date AS shipment_date,
    c.closing_date AS shipment_target_date,
    c.shipping_date,
    c.reports_availability_date,
    p.id AS provider_id,
    p.name AS provider_name,
    sc.id AS scheme_id,
    sc.name AS scheme_name,
    sv.id AS service_id,
    sv.name AS service_name,
    m.id AS method_id,
    m.name AS method_name,
    e.result_form,
    e.lab_id,
    l.code AS lab_code,
    l.name AS lab_name,
    l.contact_person_name,
    l.email_address AS lab_email,
    l.phone_number AS lab_phone,
    prov.name AS province_name,
    d.name AS district_name,
    e.enrollment_id,
    e.method_sample_id,
    ms.name AS sample_name,
    e.attribute,
    e.attribute_label,
    st.evaluation_kind,
    e.reported_numeric,
    e.reported_text,
    e.assigned_numeric,
    e.assigned_text,
    st.assigned_value_source,
    st.participant_count,
    st.reported_count,
    st.group_mean,
    st.group_median,
    st.robust_sd,
    st.standard_sd,
    e.deviation,
    e.z_score,
    e.score,
    e.max_score,
    e.grade,
    e.evaluated,
    e.not_evaluated_reason,
    e.frozen_at
   FROM ((((((((((public.pt_result_evaluations e
     JOIN public.pt_cycles c ON ((c.id = e.pt_cycle_id)))
     JOIN public.schemes sc ON ((sc.id = e.scheme_id)))
     JOIN public.providers p ON ((p.id = sc.provider_id)))
     JOIN public.services sv ON ((sv.id = e.service_id)))
     JOIN public.methods m ON ((m.id = e.method_id)))
     JOIN public.method_samples ms ON ((ms.id = e.method_sample_id)))
     JOIN public.laboratorys l ON ((l.id = e.lab_id)))
     LEFT JOIN public.provinces prov ON ((prov.id = l.province_id)))
     LEFT JOIN public.districts d ON ((d.id = l.district_id)))
     LEFT JOIN public.pt_sample_statistics st ON (((st.pt_cycle_id = e.pt_cycle_id) AND ((st.sample_group)::text = (ms.name)::text) AND ((st.attribute)::text = (e.attribute)::text))));


ALTER VIEW public.vw_pt_result_evaluation OWNER TO postgres;

--
-- Name: vw_pt_sample_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_pt_sample_summary AS
 SELECT e.pt_cycle_id,
    c.code AS cycle_code,
    sc.id AS scheme_id,
    sc.name AS scheme_name,
    sv.name AS service_name,
    m.id AS method_id,
    m.name AS method_name,
    e.result_form,
    e.method_sample_id,
    ms.name AS sample_name,
    e.attribute,
    e.attribute_label,
    max((st.evaluation_kind)::text) AS evaluation_kind,
    max(st.assigned_value_numeric) AS assigned_value_numeric,
    max((st.assigned_value_text)::text) AS assigned_value_text,
    max((st.assigned_value_source)::text) AS assigned_value_source,
    max(st.participant_count) AS pooled_participant_count,
    max(st.reported_count) AS pooled_reported_count,
    max(st.group_mean) AS group_mean,
    max(st.group_median) AS group_median,
    max(st.robust_sd) AS robust_sd,
    max(st.standard_sd) AS standard_sd,
    max(st.minimum_value) AS minimum_value,
    max(st.maximum_value) AS maximum_value,
    bool_or(st.evaluated) AS evaluated,
    max((st.not_evaluated_reason)::text) AS not_evaluated_reason,
    count(*) AS participant_count,
    count(*) FILTER (WHERE e.evaluated) AS evaluated_count,
    count(*) FILTER (WHERE ((e.grade)::text = 'Acceptable'::text)) AS acceptable_count,
    count(*) FILTER (WHERE ((e.grade)::text = 'Warning'::text)) AS warning_count,
    count(*) FILTER (WHERE ((e.grade)::text = 'Unacceptable'::text)) AS unacceptable_count,
    count(*) FILTER (WHERE (NOT e.evaluated)) AS not_evaluated_count,
    count(*) FILTER (WHERE ((e.reported_text)::text = 'DETECTED'::text)) AS detected_count,
    count(*) FILTER (WHERE ((e.reported_text)::text = 'NOT DETECTED'::text)) AS not_detected_count,
    avg(e.reported_numeric) AS platform_mean,
    max(st.frozen_at) AS frozen_at
   FROM ((((((public.pt_result_evaluations e
     JOIN public.pt_cycles c ON ((c.id = e.pt_cycle_id)))
     JOIN public.schemes sc ON ((sc.id = e.scheme_id)))
     JOIN public.services sv ON ((sv.id = e.service_id)))
     JOIN public.methods m ON ((m.id = e.method_id)))
     JOIN public.method_samples ms ON ((ms.id = e.method_sample_id)))
     LEFT JOIN public.pt_sample_statistics st ON (((st.pt_cycle_id = e.pt_cycle_id) AND ((st.sample_group)::text = (ms.name)::text) AND ((st.attribute)::text = (e.attribute)::text))))
  GROUP BY e.pt_cycle_id, c.code, sc.id, sc.name, sv.name, m.id, m.name, e.result_form, e.method_sample_id, ms.name, e.attribute, e.attribute_label;


ALTER VIEW public.vw_pt_sample_summary OWNER TO postgres;

--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: bacteriology_ast_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_ast_results ALTER COLUMN id SET DEFAULT nextval('public.bacteriology_ast_results_id_seq'::regclass);


--
-- Name: bacteriology_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results ALTER COLUMN id SET DEFAULT nextval('public.bacteriology_results_id_seq'::regclass);


--
-- Name: districts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts ALTER COLUMN id SET DEFAULT nextval('public.districts_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: hiv_eid_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results ALTER COLUMN id SET DEFAULT nextval('public.hiv_eid_results_id_seq'::regclass);


--
-- Name: hiv_vl_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results ALTER COLUMN id SET DEFAULT nextval('public.hiv_vl_results_id_seq'::regclass);


--
-- Name: lab_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types ALTER COLUMN id SET DEFAULT nextval('public.lab_types_id_seq'::regclass);


--
-- Name: laboratorys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys ALTER COLUMN id SET DEFAULT nextval('public.laboratorys_id_seq'::regclass);


--
-- Name: list_stages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_stages ALTER COLUMN id SET DEFAULT nextval('public.list_stages_id_seq'::regclass);


--
-- Name: list_statuses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_statuses ALTER COLUMN id SET DEFAULT nextval('public.list_statuses_id_seq'::regclass);


--
-- Name: meters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters ALTER COLUMN id SET DEFAULT nextval('public.meters_id_seq'::regclass);


--
-- Name: method_sample_expected_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_sample_expected_values ALTER COLUMN id SET DEFAULT nextval('public.method_sample_expected_values_id_seq'::regclass);


--
-- Name: method_samples id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples ALTER COLUMN id SET DEFAULT nextval('public.method_samples_id_seq'::regclass);


--
-- Name: methods id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods ALTER COLUMN id SET DEFAULT nextval('public.methods_id_seq'::regclass);


--
-- Name: providers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers ALTER COLUMN id SET DEFAULT nextval('public.providers_id_seq'::regclass);


--
-- Name: provinces id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces ALTER COLUMN id SET DEFAULT nextval('public.provinces_id_seq'::regclass);


--
-- Name: pt_cycle_samples id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples ALTER COLUMN id SET DEFAULT nextval('public.pt_cycle_samples_id_seq'::regclass);


--
-- Name: pt_cycle_statuses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses ALTER COLUMN id SET DEFAULT nextval('public.pt_cycle_statuses_id_seq'::regclass);


--
-- Name: pt_cycles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles ALTER COLUMN id SET DEFAULT nextval('public.pt_cycles_id_seq'::regclass);


--
-- Name: pt_enrollment_performance id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance ALTER COLUMN id SET DEFAULT nextval('public.pt_enrollment_performance_id_seq'::regclass);


--
-- Name: pt_result_evaluations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations ALTER COLUMN id SET DEFAULT nextval('public.pt_result_evaluations_id_seq'::regclass);


--
-- Name: pt_sample_statistics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics ALTER COLUMN id SET DEFAULT nextval('public.pt_sample_statistics_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: schemes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes ALTER COLUMN id SET DEFAULT nextval('public.schemes_id_seq'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services ALTER COLUMN id SET DEFAULT nextval('public.services_id_seq'::regclass);


--
-- Name: tb_xpert_ultra_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results ALTER COLUMN id SET DEFAULT nextval('public.tb_xpert_ultra_results_id_seq'::regclass);


--
-- Name: tb_xpert_xdr_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results ALTER COLUMN id SET DEFAULT nextval('public.tb_xpert_xdr_results_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.announcements (id, name, description, body, category, audience, scheme_id, pinned, publish_from, publish_until, event_at, event_ends_at, location, link_url, published_at, published_by, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Annual EQA Participants Training Day	One day, all schemes, Ndola. Registration closes two weeks before.	The annual training day covers result capture on the new platform, reading your performance report, and corrective action for unsatisfactory results. One place per participating laboratory is funded; further places are at the laboratory's own cost.	Event	All Participants	\N	t	\N	\N	2026-10-29 09:30:00+02	2026-10-29 09:30:00+02	Ndola Teaching Hospital, 7th Floor Conference Room	\N	2026-09-18 11:43:52.26729+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.241809+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.268295+02	nkoleevans@hotmail.com
2	EQA System Development Meeting	Quarterly review of the platform with participating laboratories.	Agenda: progress on the result forms now live, the bacteriology scheme's first survey, and what participants want next. Laboratories unable to attend in person may join on the link below.	Meeting	All Participants	\N	f	\N	\N	2026-09-26 09:30:00+02	\N	Hybrid - NHRTI Ndola and Teams	\N	2026-09-18 11:43:52.285815+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.277296+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.285815+02	nkoleevans@hotmail.com
3	Bacteriology Scheme Protocol TP-NHRTI-BACT-001	The scheme protocol, including the complaints and appeals procedures.	Every laboratory enrolled in the bacteriology scheme should hold a current copy of the scheme protocol. It sets out the panel, the reporting format, how results are scored, and how to appeal an evaluation. Section 17 covers the scoring criteria and the acceptable performance score.	Resource	Scheme	4	f	\N	\N	\N	\N	\N	https://nhrti.moh.gov.zm/eqa/bacteriology/TP-NHRTI-BACT-001.pdf	2026-09-18 11:43:52.303909+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.294373+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.303909+02	nkoleevans@hotmail.com
4	Bacteriology Participant Instructions and Worksheet	TF-NHRTI-BACT-003 and the worksheet TF-NHRTI-BACT-001.	Sample condition must be documented on the worksheet on receipt of the PT panel. Swabs are to be stored at room temperature for five minutes before inoculating directly onto the applicable media. Process the PT samples exactly as you would routine samples.	Resource	Scheme	4	f	\N	\N	\N	\N	\N	https://nhrti.moh.gov.zm/eqa/bacteriology/TF-NHRTI-BACT-003.pdf	2026-09-18 11:43:52.320937+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.312431+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.320937+02	nkoleevans@hotmail.com
5	Xpert Module Verification Reminder	Record the module number on every Xpert result you report.	Several results in the last round were submitted without a module number. The module is needed to investigate an unacceptable result, so a result reported without one cannot be followed up. Please check the field before submitting.	General	Scheme	1	f	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.343571+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.329527+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.344572+02	nkoleevans@hotmail.com
6	Courier Delay Affecting Northern and Muchinga Shipments	Panels dispatched last week are running about four days late.	The courier has advised of a delay on the northern route. Laboratories affected should record the actual date of receipt on their worksheets as usual; the trial closing date will be extended where the delay materially reduces testing time. Contact the scheme coordinator if your panel arrives in an unsuitable condition.	General	All Participants	\N	f	\N	2026-10-04	\N	\N	\N	\N	2026-09-18 11:43:52.367178+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.353092+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.368183+02	nkoleevans@hotmail.com
7	Viral Load Round VL-2027-A Opens for Enrolment	Enrol from My Enrolments before the closing date.	Enrolment for the first viral load round of 2027 is now open. Laboratories running more than one platform should enrol each platform separately, as each receives its own panel.	General	Scheme	2	f	2026-10-14	\N	\N	\N	\N	\N	2026-09-18 11:43:52.396866+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.383232+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.396866+02	nkoleevans@hotmail.com
8	Draft - Scheme Fee Schedule 2027	Not for circulation until finance has signed it off.	The 2027 fee schedule is being finalised and will be circulated once approved.	General	All Participants	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	2	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.412216+02	nkoleevans@hotmail.com	\N	\N
9	Withdrawal of Survey BACT-01-2026 Feedback Report	An earlier version of the report was issued in error.	The feedback report circulated for survey BACT-01-2026 contained an error in the AST evaluation table. A corrected report has been issued. Please discard the earlier version.	General	Scheme	4	f	\N	2026-09-09	\N	\N	\N	\N	2026-09-18 11:43:52.446375+02	nkoleevans@hotmail.com	2	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.42805+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.446375+02	nkoleevans@hotmail.com
10	Change to the Acceptable Performance Score	Reviewed by a second officer before circulation.	Participants are reminded that the acceptable performance score for the bacteriology scheme is 100%. Laboratories scoring below this should initiate corrective action in line with their own quality management procedures and retain the PT samples until the performance report is received.	General	All Participants	\N	f	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:52.507044+02	head@cdl.moh.gov.zm	2	4	5	2	2026-09-18 11:43:52.490458+02	quality@cdl.moh.gov.zm	Wording agreed with the scheme head	2026-09-18 11:43:52.507044+02	head@cdl.moh.gov.zm	Wording agreed with the scheme head	\N	\N	\N	2026-09-18 11:43:52.454376+02	nkoleevans@hotmail.com	2026-09-18 11:43:52.508048+02	head@cdl.moh.gov.zm
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applications (id, name, description, lab_id, scheme_id, service_id, method_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
14	Solwezi Mine Clinic Lab - Ultra	Application by Solwezi Mine Clinic Lab to take part in Ultra	8	1	2	1	\N	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.804046+02	brian.kunda@solwezi.health.zm	\N	\N
1	Levy Mwanawasa University Teaching Hospital - Ultra	Application by Levy Mwanawasa University Teaching Hospital to take part in Ultra	1	1	2	1	1	4	5	1	2026-09-18 11:43:41.981146+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.745272+02	musachoolwe@gmail.com	2026-09-18 11:43:41.981881+02	wanangwa@gmail.com
2	Levy Mwanawasa University Teaching Hospital - XDR	Application by Levy Mwanawasa University Teaching Hospital to take part in XDR	1	1	2	2	1	4	5	1	2026-09-18 11:43:41.981146+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.751808+02	musachoolwe@gmail.com	2026-09-18 11:43:41.981881+02	wanangwa@gmail.com
3	Levy Mwanawasa University Teaching Hospital - Hologic Panther	Application by Levy Mwanawasa University Teaching Hospital to take part in Hologic Panther	1	2	3	7	1	4	5	1	2026-09-18 11:43:41.981146+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.753323+02	musachoolwe@gmail.com	2026-09-18 11:43:41.981881+02	wanangwa@gmail.com
4	Levy Mwanawasa University Teaching Hospital - GeneXpert HIV-1 Qual	Application by Levy Mwanawasa University Teaching Hospital to take part in GeneXpert HIV-1 Qual	1	3	4	9	1	4	5	1	2026-09-18 11:43:41.981146+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.754334+02	musachoolwe@gmail.com	2026-09-18 11:43:41.981881+02	wanangwa@gmail.com
5	Levy Lusaka Laboratory - Ultra	Application by Levy Lusaka Laboratory to take part in Ultra	2	1	2	1	1	4	5	1	2026-09-18 11:43:42.163369+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.764879+02	jane@gmail.com	2026-09-18 11:43:42.163369+02	wanangwa@gmail.com
6	Private Lab 1 - Ziehl-Neelsen	Application by Private Lab 1 to take part in Ziehl-Neelsen	3	1	1	3	1	4	5	1	2026-09-18 11:43:42.31586+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.773918+02	markdoe@gmail.com	2026-09-18 11:43:42.316862+02	wanangwa@gmail.com
7	Private Lab 1 - Ultra	Application by Private Lab 1 to take part in Ultra	3	1	2	1	1	4	5	1	2026-09-18 11:43:42.31586+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.773918+02	markdoe@gmail.com	2026-09-18 11:43:42.316862+02	wanangwa@gmail.com
8	UTH New Lab - Ultra	Application by UTH New Lab to take part in Ultra	4	1	2	1	1	4	5	1	2026-09-18 11:43:42.448521+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.780923+02	alanphiri@gmail.com	2026-09-18 11:43:42.448521+02	wanangwa@gmail.com
9	UTH New Lab - XDR	Application by UTH New Lab to take part in XDR	4	1	2	2	1	4	5	1	2026-09-18 11:43:42.448521+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.780923+02	alanphiri@gmail.com	2026-09-18 11:43:42.448521+02	wanangwa@gmail.com
10	Ndola Teaching Hospital Lab - Ultra	Application by Ndola Teaching Hospital Lab to take part in Ultra	5	1	2	1	1	4	5	1	2026-09-18 11:43:42.565286+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.787923+02	grace.mulenga@ndola.health.zm	2026-09-18 11:43:42.565286+02	wanangwa@gmail.com
11	Kitwe Central Hospital Lab - Ultra	Application by Kitwe Central Hospital Lab to take part in Ultra	6	1	2	1	1	4	5	1	2026-09-18 11:43:42.694798+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.792994+02	peter.zulu@kitwe.health.zm	2026-09-18 11:43:42.694798+02	wanangwa@gmail.com
12	Kitwe Central Hospital Lab - XDR	Application by Kitwe Central Hospital Lab to take part in XDR	6	1	2	2	1	4	5	1	2026-09-18 11:43:42.694798+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.793995+02	peter.zulu@kitwe.health.zm	2026-09-18 11:43:42.694798+02	wanangwa@gmail.com
13	Livingstone Central Hospital Lab - Ultra	Application by Livingstone Central Hospital Lab to take part in Ultra	7	1	2	1	1	5	2	1	2026-09-18 11:43:42.767242+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.79902+02	naomi.sakala@livingstone.health.zm	2026-09-18 11:43:42.767242+02	wanangwa@gmail.com
15	Arthur Davison Childrens Hospital Lab - Abbott m2000	Application by Arthur Davison Childrens Hospital Lab to take part in Abbott m2000	9	2	3	5	1	4	5	1	2026-09-18 11:43:42.832542+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.810689+02	chanda.mwape@adch.health.zm	2026-09-18 11:43:42.833541+02	wanangwa@gmail.com
16	Chipata Central Hospital Lab - Roche Cobas 6800	Application by Chipata Central Hospital Lab to take part in Roche Cobas 6800	10	2	3	6	1	4	5	1	2026-09-18 11:43:42.962505+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.816686+02	foster.tembo@chipata.health.zm	2026-09-18 11:43:42.963505+02	wanangwa@gmail.com
17	Kabwe General Hospital Lab - Abbott m2000	Application by Kabwe General Hospital Lab to take part in Abbott m2000	11	2	3	5	1	4	5	1	2026-09-18 11:43:43.079816+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.827707+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:43.080815+02	wanangwa@gmail.com
18	Kabwe General Hospital Lab - Hologic Panther	Application by Kabwe General Hospital Lab to take part in Hologic Panther	11	2	3	7	1	4	5	1	2026-09-18 11:43:43.079816+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.828707+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:43.080815+02	wanangwa@gmail.com
20	Mansa General Hospital Lab - Cobas 4800	Application by Mansa General Hospital Lab to take part in Cobas 4800	12	3	4	8	1	4	5	1	2026-09-18 11:43:43.200096+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.835222+02	chola.mumba@mansa.health.zm	2026-09-18 11:43:43.200096+02	wanangwa@gmail.com
21	Mongu Provincial Hospital Lab - GeneXpert HIV-1 Qual	Application by Mongu Provincial Hospital Lab to take part in GeneXpert HIV-1 Qual	13	3	4	9	1	4	5	1	2026-09-18 11:43:43.316591+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.84009+02	situmbeko.imwiko@mongu.health.zm	2026-09-18 11:43:43.31833+02	wanangwa@gmail.com
22	Ndola Teaching Hospital Microbiology - Manual	Application by Ndola Teaching Hospital Microbiology to take part in Manual	14	4	5	10	1	4	5	1	2026-09-18 11:43:43.446064+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.845156+02	mwila.chibesa@ndolamicro.health.zm	2026-09-18 11:43:43.446064+02	wanangwa@gmail.com
23	Kitwe Teaching Hospital Microbiology - Manual	Application by Kitwe Teaching Hospital Microbiology to take part in Manual	15	4	5	10	1	4	5	1	2026-09-18 11:43:43.57893+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.850665+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:43.579932+02	wanangwa@gmail.com
25	Lusaka Trust Hospital Laboratory - Automated	Application by Lusaka Trust Hospital Laboratory to take part in Automated	16	4	5	11	1	4	5	1	2026-09-18 11:43:43.719992+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.857185+02	davies.simukonda@lth.co.zm	2026-09-18 11:43:43.72099+02	wanangwa@gmail.com
19	Kabwe General Hospital Lab - Cobas 4800	Application by Kabwe General Hospital Lab to take part in Cobas 4800	11	3	4	8	1	4	5	1	2026-09-18 11:43:43.079816+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.828707+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:43.080815+02	wanangwa@gmail.com
24	Kitwe Teaching Hospital Microbiology - Automated	Application by Kitwe Teaching Hospital Microbiology to take part in Automated	15	4	5	11	1	4	5	1	2026-09-18 11:43:43.57893+02	wanangwa@gmail.com	Set by the laboratory registration review	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.851671+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:43.579932+02	wanangwa@gmail.com
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attachments (id, name, path, filesize, filetype, parent, type, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: audits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audits (id, user_id, user_email, token, date, feature, model, object_id, action, before, after, created_at, created_by) FROM stdin;
1	0	nkoleevans@hotmail.com	public	2026-07-22 05:35:19+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-22 05:35:20.207287+02	nkoleevans@hotmail.com
2	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:31+02	Session	\N	\N	Start	null	{"exp": 1784693131, "jti": "4d7e1cabd583411b82057e8f959d513f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 05:35:31.574841+02	nkoleevans@gmail.com
3	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:40+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:35:41.431763+02	nkoleevans@gmail.com
4	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:42+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 05:35:43.342368+02	nkoleevans@gmail.com
5	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:45+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 05:35:45.943794+02	nkoleevans@gmail.com
6	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:35:47+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:35:47.988106+02	nkoleevans@gmail.com
7	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:36:07+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:36:07.918857+02	nkoleevans@gmail.com
8	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:37:22+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:37:22.555371+02	nkoleevans@gmail.com
9	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:37:28+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 05:37:29.424247+02	nkoleevans@gmail.com
10	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:37:30+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:37:30.925525+02	nkoleevans@gmail.com
11	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:39:54+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:39:54.782528+02	nkoleevans@gmail.com
12	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:41+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:43.29577+02	nkoleevans@gmail.com
13	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:46.733093+02	nkoleevans@gmail.com
14	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:51+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:52.326936+02	nkoleevans@gmail.com
15	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:52+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:53.458609+02	nkoleevans@gmail.com
16	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:53+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:54.395348+02	nkoleevans@gmail.com
17	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:55+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:56.010372+02	nkoleevans@gmail.com
18	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:57+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:45:57.846121+02	nkoleevans@gmail.com
19	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:45:59+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:00.477595+02	nkoleevans@gmail.com
20	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:02+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:04.049806+02	nkoleevans@gmail.com
21	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:14.787203+02	nkoleevans@gmail.com
22	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:16+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:17.505026+02	nkoleevans@gmail.com
23	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:17+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 05:46:17.98723+02	nkoleevans@gmail.com
24	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:18+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 05:46:19.236912+02	nkoleevans@gmail.com
25	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:46:19+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:46:20.138862+02	nkoleevans@gmail.com
26	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:48:34+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:48:36.678629+02	nkoleevans@gmail.com
27	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:49:18+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:49:19.509363+02	nkoleevans@gmail.com
28	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:49:32+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 05:49:35.078891+02	nkoleevans@gmail.com
29	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:00+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:00.959272+02	nkoleevans@gmail.com
30	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:01+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:02.067161+02	nkoleevans@gmail.com
31	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:01+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:02.56924+02	nkoleevans@gmail.com
32	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:02+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:02.939891+02	nkoleevans@gmail.com
33	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:02+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:03.352519+02	nkoleevans@gmail.com
34	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:50:03+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:50:03.872692+02	nkoleevans@gmail.com
35	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:42+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:45.502563+02	nkoleevans@gmail.com
36	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:53+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:54.113877+02	nkoleevans@gmail.com
37	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:56.893925+02	nkoleevans@gmail.com
38	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:56+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:57.38431+02	nkoleevans@gmail.com
39	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:52:58+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:52:59.402343+02	nkoleevans@gmail.com
40	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:30.922883+02	nkoleevans@gmail.com
41	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:32.421078+02	nkoleevans@gmail.com
42	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:37.902971+02	nkoleevans@gmail.com
43	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:39+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:40.307832+02	nkoleevans@gmail.com
45	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:41+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:42.491305+02	nkoleevans@gmail.com
46	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:42.961879+02	nkoleevans@gmail.com
48	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:44+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:46.681992+02	nkoleevans@gmail.com
49	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:46+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:47.122891+02	nkoleevans@gmail.com
44	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:41+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:41.929211+02	nkoleevans@gmail.com
47	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:53:43+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:53:44.827386+02	nkoleevans@gmail.com
50	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:28+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:31.057901+02	nkoleevans@gmail.com
51	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:32+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:32.871597+02	nkoleevans@gmail.com
52	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:33+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:34.335424+02	nkoleevans@gmail.com
53	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:37+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:38.254482+02	nkoleevans@gmail.com
54	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:39.26101+02	nkoleevans@gmail.com
55	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:40+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:40.563763+02	nkoleevans@gmail.com
56	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:54:56+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 05:54:59.28403+02	nkoleevans@gmail.com
57	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:29+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:29.564669+02	nkoleevans@gmail.com
58	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:29+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:30.364984+02	nkoleevans@gmail.com
59	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:30+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:31.365755+02	nkoleevans@gmail.com
60	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:33+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:35.380859+02	nkoleevans@gmail.com
61	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:37+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:37.977433+02	nkoleevans@gmail.com
62	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:55:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:55:38.945842+02	nkoleevans@gmail.com
63	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:57:07+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:57:10.999385+02	nkoleevans@gmail.com
64	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 05:59:10+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 05:59:10.670507+02	nkoleevans@gmail.com
65	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 06:02:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:02:22.22293+02	nkoleevans@gmail.com
66	1	nkoleevans@gmail.com	4d7e1cabd583411b82057e8f959d513f	2026-07-22 06:03:41+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:03:41.711982+02	nkoleevans@gmail.com
67	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:05:35+02	Session	\N	\N	Start	null	{"exp": 1784694935, "jti": "5afc934a75ce42c1a0b94b870c414725", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 06:05:35.651638+02	nkoleevans@gmail.com
68	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:07:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:07:34.733452+02	nkoleevans@gmail.com
69	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:07:35+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:07:36.100408+02	nkoleevans@gmail.com
70	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:07:40+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:07:41.391913+02	nkoleevans@gmail.com
71	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:08:01+02	Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:08:01.902479+02	nkoleevans@gmail.com
72	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:09:45+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:09:47.878893+02	nkoleevans@gmail.com
73	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:09:56+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:09:56.691331+02	nkoleevans@gmail.com
74	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:03.416069+02	nkoleevans@gmail.com
75	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:04+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:05.002825+02	nkoleevans@gmail.com
76	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:17+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:17.907225+02	nkoleevans@gmail.com
77	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:27+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:27.81358+02	nkoleevans@gmail.com
78	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:30+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:31.193482+02	nkoleevans@gmail.com
79	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:10:36+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:10:36.826353+02	nkoleevans@gmail.com
80	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:33.853217+02	nkoleevans@gmail.com
81	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:36.029836+02	nkoleevans@gmail.com
82	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:36+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:37.132904+02	nkoleevans@gmail.com
83	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:38+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:38.594985+02	nkoleevans@gmail.com
84	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:40+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:40.955738+02	nkoleevans@gmail.com
85	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:41+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:43.147611+02	nkoleevans@gmail.com
86	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:45+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:46.647973+02	nkoleevans@gmail.com
87	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:12:46+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:12:48.123458+02	nkoleevans@gmail.com
88	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:54+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:54.641691+02	nkoleevans@gmail.com
89	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:57+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:57.905984+02	nkoleevans@gmail.com
90	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:58+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:59.337841+02	nkoleevans@gmail.com
91	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:14:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:14:59.904658+02	nkoleevans@gmail.com
92	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:15:00+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:15:00.705473+02	nkoleevans@gmail.com
93	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:15:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:15:02.496687+02	nkoleevans@gmail.com
94	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:15:02+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:15:03.057095+02	nkoleevans@gmail.com
95	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:15+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:15.932236+02	nkoleevans@gmail.com
96	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:16+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:17.272399+02	nkoleevans@gmail.com
97	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:18+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:18.717737+02	nkoleevans@gmail.com
98	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:19+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:19.649481+02	nkoleevans@gmail.com
99	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:19+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:20.430336+02	nkoleevans@gmail.com
100	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:23+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:23.916596+02	nkoleevans@gmail.com
101	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:24+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:24.951161+02	nkoleevans@gmail.com
102	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:24+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:25.475492+02	nkoleevans@gmail.com
103	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:25+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:26.354966+02	nkoleevans@gmail.com
104	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:26+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:26.93155+02	nkoleevans@gmail.com
105	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:26+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:27.482629+02	nkoleevans@gmail.com
106	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:29+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:29.92587+02	nkoleevans@gmail.com
107	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:16:32+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:16:32.95779+02	nkoleevans@gmail.com
108	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:07+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:07.843182+02	nkoleevans@gmail.com
109	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:08+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:08.996481+02	nkoleevans@gmail.com
110	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:09+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:11.071344+02	nkoleevans@gmail.com
111	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:11+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:12.190885+02	nkoleevans@gmail.com
112	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:12+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:13.329256+02	nkoleevans@gmail.com
113	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:19:14+02	PT Cycle Samples List	\N	\N	View - Allowed	null	null	2026-07-22 06:19:14.990684+02	nkoleevans@gmail.com
114	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:13+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:14.82198+02	nkoleevans@gmail.com
115	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:14+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:14.971342+02	nkoleevans@gmail.com
116	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:16.648089+02	nkoleevans@gmail.com
117	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:16+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:17.251806+02	nkoleevans@gmail.com
118	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:17+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:17.692035+02	nkoleevans@gmail.com
119	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:17+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:18.201017+02	nkoleevans@gmail.com
120	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:19+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:19.654953+02	nkoleevans@gmail.com
121	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:19+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:20.134427+02	nkoleevans@gmail.com
122	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:20+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:21.3856+02	nkoleevans@gmail.com
123	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:21+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:22.264122+02	nkoleevans@gmail.com
124	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:22+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:22.801435+02	nkoleevans@gmail.com
125	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:22+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:23.441762+02	nkoleevans@gmail.com
126	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:47+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:48.074182+02	nkoleevans@gmail.com
127	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:51+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:51.71363+02	nkoleevans@gmail.com
128	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:53+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:54.214301+02	nkoleevans@gmail.com
129	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:20:54+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:20:59.391196+02	nkoleevans@gmail.com
130	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:23:09+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:23:12.417885+02	nkoleevans@gmail.com
131	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:23:13+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:23:14.195589+02	nkoleevans@gmail.com
132	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:23:14+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:23:14.942534+02	nkoleevans@gmail.com
133	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:01+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:04.020237+02	nkoleevans@gmail.com
134	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:04.31496+02	nkoleevans@gmail.com
135	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:05+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:05.754088+02	nkoleevans@gmail.com
136	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:06+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:07.40278+02	nkoleevans@gmail.com
137	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:45+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:46.136727+02	nkoleevans@gmail.com
138	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:46+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:47.30531+02	nkoleevans@gmail.com
139	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:24:48+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:24:49.227522+02	nkoleevans@gmail.com
140	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:25:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:25:46.541141+02	nkoleevans@gmail.com
141	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:25:48+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:25:48.57849+02	nkoleevans@gmail.com
142	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:26:40+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:26:43.366007+02	nkoleevans@gmail.com
143	1	nkoleevans@gmail.com	5afc934a75ce42c1a0b94b870c414725	2026-07-22 06:30:50+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:30:52.043239+02	nkoleevans@gmail.com
144	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:39:36+02	Session	\N	\N	Start	null	{"exp": 1784696976, "jti": "cef71fe6140c479ab739632c5be32fad", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 06:39:37.588474+02	nkoleevans@gmail.com
145	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:39:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:39:43.613898+02	nkoleevans@gmail.com
146	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:39:45+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:39:45.654958+02	nkoleevans@gmail.com
147	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:04.961103+02	nkoleevans@gmail.com
148	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:06+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-22 06:40:06.893884+02	nkoleevans@gmail.com
149	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:08.581123+02	nkoleevans@gmail.com
150	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:08+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:10.408715+02	nkoleevans@gmail.com
151	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:10+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:10.899555+02	nkoleevans@gmail.com
152	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:22.405278+02	nkoleevans@gmail.com
153	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:24+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:24.669911+02	nkoleevans@gmail.com
154	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:25+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:28.879724+02	nkoleevans@gmail.com
155	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:43+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:43.752872+02	nkoleevans@gmail.com
156	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:46+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:47.884506+02	nkoleevans@gmail.com
157	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:48+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:40:49.288677+02	nkoleevans@gmail.com
158	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:49+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:40:50.196898+02	nkoleevans@gmail.com
159	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:40:56+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:41:00.01118+02	nkoleevans@gmail.com
160	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:42:50+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-22 06:42:53.018954+02	nkoleevans@gmail.com
161	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:00+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:00.734886+02	nkoleevans@gmail.com
162	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:01+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:02.43168+02	nkoleevans@gmail.com
163	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:03+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:03.897287+02	nkoleevans@gmail.com
164	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:03+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:04.279293+02	nkoleevans@gmail.com
165	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:06+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:06.674185+02	nkoleevans@gmail.com
166	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:07+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:08.101652+02	nkoleevans@gmail.com
167	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:08+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:08.645198+02	nkoleevans@gmail.com
168	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:11.544893+02	nkoleevans@gmail.com
169	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:24+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:25.332311+02	nkoleevans@gmail.com
170	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:43:25+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:43:26.345269+02	nkoleevans@gmail.com
171	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:44:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:44:11.601114+02	nkoleevans@gmail.com
172	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:44:53+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 06:44:53.613197+02	nkoleevans@gmail.com
173	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:24+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:24.731679+02	nkoleevans@gmail.com
174	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:25+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:25.961685+02	nkoleevans@gmail.com
175	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:26+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:26.69854+02	nkoleevans@gmail.com
176	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:53:54+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 06:53:55.76551+02	nkoleevans@gmail.com
177	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 06:54:00+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 06:54:01.098392+02	nkoleevans@gmail.com
178	1	nkoleevans@gmail.com	cef71fe6140c479ab739632c5be32fad	2026-07-22 07:07:12+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:07:15.459201+02	nkoleevans@gmail.com
179	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:12:51+02	Session	\N	\N	Start	null	{"exp": 1784698971, "jti": "fcd5bf456fec4d3b8f37668e59a49f82", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 07:12:53.339178+02	nkoleevans@gmail.com
180	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:12:53+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 07:12:54.321503+02	nkoleevans@gmail.com
181	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:12:54+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:12:55.137872+02	nkoleevans@gmail.com
182	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:13:21+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:13:24.623066+02	nkoleevans@gmail.com
183	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:14:39+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:14:42.124051+02	nkoleevans@gmail.com
184	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:22+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:23.384998+02	nkoleevans@gmail.com
185	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:23+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:23.970733+02	nkoleevans@gmail.com
186	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:24+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:25.215808+02	nkoleevans@gmail.com
187	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:16:27+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:16:27.583831+02	nkoleevans@gmail.com
188	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:39+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:40.248053+02	nkoleevans@gmail.com
189	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:41+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:41.873334+02	nkoleevans@gmail.com
190	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:44+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 07:19:45.011624+02	nkoleevans@gmail.com
191	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:45+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 07:19:45.691914+02	nkoleevans@gmail.com
192	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:45+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:46.524291+02	nkoleevans@gmail.com
193	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:48+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:48.867679+02	nkoleevans@gmail.com
194	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:19:49+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 07:19:50.457352+02	nkoleevans@gmail.com
195	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:12+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:13.419006+02	nkoleevans@gmail.com
196	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:14+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:15.387433+02	nkoleevans@gmail.com
197	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:20.928169+02	nkoleevans@gmail.com
198	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:22+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:23.160578+02	nkoleevans@gmail.com
199	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:23+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:24.714867+02	nkoleevans@gmail.com
200	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:24+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:25.263875+02	nkoleevans@gmail.com
201	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:25+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:26.955221+02	nkoleevans@gmail.com
202	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:26+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:27.501906+02	nkoleevans@gmail.com
203	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:27+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:27.95186+02	nkoleevans@gmail.com
204	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:29+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 07:20:30.063839+02	nkoleevans@gmail.com
205	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:20:33+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:20:34.077562+02	nkoleevans@gmail.com
206	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:33:31+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:33:32.329323+02	nkoleevans@gmail.com
207	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:33:40+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 07:33:43.173327+02	nkoleevans@gmail.com
208	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:33:57+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:33:58.659073+02	nkoleevans@gmail.com
209	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:01+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-22 07:34:02.311656+02	nkoleevans@gmail.com
210	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:21+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:34:22.600521+02	nkoleevans@gmail.com
211	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:42+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:34:42.717401+02	nkoleevans@gmail.com
212	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:45+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:34:45.571856+02	nkoleevans@gmail.com
213	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:34:47+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:34:47.76451+02	nkoleevans@gmail.com
214	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:37:16+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:37:18.815424+02	nkoleevans@gmail.com
215	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:38:21+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:38:23.868133+02	nkoleevans@gmail.com
216	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:38:45+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:38:46.480324+02	nkoleevans@gmail.com
217	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:40:12+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:40:13.309466+02	nkoleevans@gmail.com
218	1	nkoleevans@gmail.com	fcd5bf456fec4d3b8f37668e59a49f82	2026-07-22 07:40:18+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:40:21.15946+02	nkoleevans@gmail.com
219	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:42:54+02	Session	\N	\N	Start	null	{"exp": 1784700774, "jti": "413cb336b95b4e328f8484e240341660", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 07:42:55.045923+02	nkoleevans@gmail.com
220	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:42:56+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:42:56.964805+02	nkoleevans@gmail.com
221	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:42:57+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:42:57.947764+02	nkoleevans@gmail.com
222	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:43:05+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:43:08.227749+02	nkoleevans@gmail.com
223	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:25+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:44:27.514874+02	nkoleevans@gmail.com
224	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:43+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:44:43.622833+02	nkoleevans@gmail.com
225	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:53+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:44:54.29115+02	nkoleevans@gmail.com
226	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:44:58+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:44:58.73446+02	nkoleevans@gmail.com
227	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:45:55+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:45:58.400781+02	nkoleevans@gmail.com
228	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:46:01+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:46:01.735051+02	nkoleevans@gmail.com
229	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:38+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:52:40.448188+02	nkoleevans@gmail.com
230	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:44+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:52:44.863246+02	nkoleevans@gmail.com
231	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:55+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:52:56.060981+02	nkoleevans@gmail.com
232	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:52:56+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 07:52:57.364147+02	nkoleevans@gmail.com
233	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:04+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:05.325217+02	nkoleevans@gmail.com
234	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:15+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:15.666248+02	nkoleevans@gmail.com
235	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:16+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:17.000937+02	nkoleevans@gmail.com
236	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:17+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:17.917107+02	nkoleevans@gmail.com
237	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:17+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:18.478241+02	nkoleevans@gmail.com
238	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:28+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:29.302309+02	nkoleevans@gmail.com
239	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:29+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:29.884584+02	nkoleevans@gmail.com
240	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:29+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:31.289946+02	nkoleevans@gmail.com
241	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:35.14677+02	nkoleevans@gmail.com
242	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:35+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:35.679679+02	nkoleevans@gmail.com
243	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:35+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:36.54391+02	nkoleevans@gmail.com
244	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:36+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:37.089433+02	nkoleevans@gmail.com
245	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:37+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:39.151583+02	nkoleevans@gmail.com
246	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:43+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 07:53:44.286667+02	nkoleevans@gmail.com
247	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:44+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 07:53:44.811564+02	nkoleevans@gmail.com
248	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:45+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:46.114849+02	nkoleevans@gmail.com
249	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:48+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:49.856533+02	nkoleevans@gmail.com
250	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:50+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:50.829308+02	nkoleevans@gmail.com
251	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:51+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-22 07:53:52.276581+02	nkoleevans@gmail.com
252	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:55+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:55.611939+02	nkoleevans@gmail.com
253	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:56+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 07:53:56.98208+02	nkoleevans@gmail.com
254	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:53:59+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 07:53:59.650326+02	nkoleevans@gmail.com
255	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:54:01+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:54:02.204475+02	nkoleevans@gmail.com
256	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:54:02+02	Review Method	\N	\N	View - Allowed	null	null	2026-07-22 07:54:03.25173+02	nkoleevans@gmail.com
257	1	nkoleevans@gmail.com	413cb336b95b4e328f8484e240341660	2026-07-22 07:54:09+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 07:54:09.678457+02	nkoleevans@gmail.com
258	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:50:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:50:32.41947+02	admin@gmail.com
259	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:50:37+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 12:50:44.529004+02	admin@gmail.com
260	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:49+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:52.470094+02	admin@gmail.com
261	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:52+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:52.975943+02	admin@gmail.com
262	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:54+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:55.075323+02	admin@gmail.com
263	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:51:56+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 12:51:57.100769+02	admin@gmail.com
264	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:52:44+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 12:52:45.406232+02	admin@gmail.com
265	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:52:46+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 12:52:46.765929+02	admin@gmail.com
266	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:52:48+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 12:52:53.191128+02	admin@gmail.com
267	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:53:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:53:22.425721+02	admin@gmail.com
268	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:53:22+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:53:22.949564+02	admin@gmail.com
269	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:53:25+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 12:53:25.977504+02	admin@gmail.com
270	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:57:54+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:57:55.451676+02	admin@gmail.com
271	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:02+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:02.619612+02	admin@gmail.com
272	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:03+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:04.70007+02	admin@gmail.com
273	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:15.008991+02	admin@gmail.com
274	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:22.34875+02	admin@gmail.com
275	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 12:58:21+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 12:58:22.462457+02	admin@gmail.com
276	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 13:00:38+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 13:00:40.299787+02	admin@gmail.com
277	1	admin@gmail.com	3e110d7f7a0f44f5bc074709b4ea7d17	2026-07-22 13:00:40+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 13:00:41.101066+02	admin@gmail.com
278	0	admin@gmail.com	public	2026-07-22 15:31:33+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-22 15:31:33.77183+02	admin@gmail.com
279	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:07+02	Session	\N	\N	Start	null	{"exp": 1784728927, "jti": "783431e259534bce83df240cb5ed1752", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 15:32:08.431534+02	nkoleevans@gmail.com
280	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:16+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 15:32:17.48437+02	nkoleevans@gmail.com
281	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:18+02	Role List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:19.10875+02	nkoleevans@gmail.com
282	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:20+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 15:32:20.637664+02	nkoleevans@gmail.com
283	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:20+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-22 15:32:21.020913+02	nkoleevans@gmail.com
284	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:21+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:21.825736+02	nkoleevans@gmail.com
285	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:23+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:24.032655+02	nkoleevans@gmail.com
286	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:24+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:24.826051+02	nkoleevans@gmail.com
287	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:25+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:25.882949+02	nkoleevans@gmail.com
288	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:26+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:26.741726+02	nkoleevans@gmail.com
289	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:27+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:27.727502+02	nkoleevans@gmail.com
290	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:28+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:29.01185+02	nkoleevans@gmail.com
291	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:30+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:30.755807+02	nkoleevans@gmail.com
292	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:33+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:32:33.832187+02	nkoleevans@gmail.com
293	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:32:35+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 15:32:35.935421+02	nkoleevans@gmail.com
294	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:01+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:02.375216+02	nkoleevans@gmail.com
295	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:06+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:06.776659+02	nkoleevans@gmail.com
296	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:07+02	Method	\N	\N	View - Allowed	null	null	2026-07-22 15:33:08.233157+02	nkoleevans@gmail.com
297	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:22+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:23.350584+02	nkoleevans@gmail.com
298	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:36+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:37.146968+02	nkoleevans@gmail.com
299	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:37+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:38.309477+02	nkoleevans@gmail.com
300	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:38+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:39.248856+02	nkoleevans@gmail.com
301	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:39+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:40.313565+02	nkoleevans@gmail.com
303	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:44.261617+02	nkoleevans@gmail.com
304	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:44+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:45.310215+02	nkoleevans@gmail.com
305	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:45+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:45.902625+02	nkoleevans@gmail.com
307	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:47+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:47.671131+02	nkoleevans@gmail.com
308	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:48+02	Users	\N	\N	View - Allowed	null	null	2026-07-22 15:33:49.017953+02	nkoleevans@gmail.com
309	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:43:54+02	Session	\N	\N	Start	null	{"exp": 1784729634, "jti": "ff48cc35d4634599a4a5c6e0c799e947", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-22 15:43:55.368882+02	nkoleevans@gmail.com
310	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:08+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 15:44:08.539159+02	nkoleevans@gmail.com
311	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:08+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:09.516304+02	nkoleevans@gmail.com
312	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:28+02	Province List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:29.405169+02	nkoleevans@gmail.com
313	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:38+02	District List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:38.734294+02	nkoleevans@gmail.com
314	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:40+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-22 15:44:41.472928+02	nkoleevans@gmail.com
315	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:45+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:46.240099+02	nkoleevans@gmail.com
302	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:41+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 15:33:41.561717+02	nkoleevans@gmail.com
316	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:54+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-22 15:44:54.936094+02	nkoleevans@gmail.com
317	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:44:57+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:44:58.321595+02	nkoleevans@gmail.com
318	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:18+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:18.690418+02	nkoleevans@gmail.com
325	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:46:00+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-22 15:46:01.378649+02	nkoleevans@gmail.com
326	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:46:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 15:46:22.284915+02	nkoleevans@gmail.com
327	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:47:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:47:09.467888+02	nkoleevans@gmail.com
306	1	nkoleevans@gmail.com	783431e259534bce83df240cb5ed1752	2026-07-22 15:33:46+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-22 15:33:47.297433+02	nkoleevans@gmail.com
319	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:23+02	Service	\N	\N	View - Allowed	null	null	2026-07-22 15:45:24.421867+02	nkoleevans@gmail.com
320	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:31+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:31.773891+02	nkoleevans@gmail.com
321	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:32+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:32.889238+02	nkoleevans@gmail.com
322	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:45+02	Service List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:45.739968+02	nkoleevans@gmail.com
323	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:46+02	Method List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:47.481624+02	nkoleevans@gmail.com
324	1	nkoleevans@gmail.com	ff48cc35d4634599a4a5c6e0c799e947	2026-07-22 15:45:59+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-22 15:45:59.596857+02	nkoleevans@gmail.com
328	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:23+02	Session	\N	\N	Start	null	{"exp": 1784806103, "jti": "642463dd03654483a4c26f1f9611aed7", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 12:58:24.388392+02	nkoleevans@gmail.com
329	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:28+02	Users	\N	\N	View - Allowed	null	null	2026-07-23 12:58:29.677805+02	nkoleevans@gmail.com
330	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:29+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:30.423071+02	nkoleevans@gmail.com
331	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:31.581233+02	nkoleevans@gmail.com
332	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:31+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:32.354143+02	nkoleevans@gmail.com
333	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:32+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:33.166716+02	nkoleevans@gmail.com
334	1	nkoleevans@gmail.com	642463dd03654483a4c26f1f9611aed7	2026-07-23 12:58:33+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 12:58:34.182193+02	nkoleevans@gmail.com
335	0	nkoleevans@hotmail.com	public	2026-07-23 13:08:47+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-23 13:08:48.146707+02	nkoleevans@hotmail.com
336	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:51+02	Session	\N	\N	Start	null	{"exp": 1784806731, "jti": "67e09fed1e1e47caaf76003f2c8236d3", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 13:08:52.070795+02	nkoleevans@gmail.com
337	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:53+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:54.5143+02	nkoleevans@gmail.com
338	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:54+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:55.424763+02	nkoleevans@gmail.com
339	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:55+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:56.428308+02	nkoleevans@gmail.com
340	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:58+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:58.652275+02	nkoleevans@gmail.com
341	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:08:58+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:08:59.251141+02	nkoleevans@gmail.com
342	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:10:43+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:10:45.499652+02	nkoleevans@gmail.com
343	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:10:41+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:10:45.736167+02	nkoleevans@gmail.com
344	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:11:51+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:11:54.919766+02	nkoleevans@gmail.com
345	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:17+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:23.491961+02	nkoleevans@gmail.com
346	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:17+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:23.817028+02	nkoleevans@gmail.com
347	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:18+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:23.828196+02	nkoleevans@gmail.com
348	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:29+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:29.739264+02	nkoleevans@gmail.com
349	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:29+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:30.985519+02	nkoleevans@gmail.com
350	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:32.456625+02	nkoleevans@gmail.com
351	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:34+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:35.300902+02	nkoleevans@gmail.com
352	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:35+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:36.047222+02	nkoleevans@gmail.com
353	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:36+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:36.738245+02	nkoleevans@gmail.com
354	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:36+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:37.169847+02	nkoleevans@gmail.com
355	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:37+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:37.583185+02	nkoleevans@gmail.com
356	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:38+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:38.984977+02	nkoleevans@gmail.com
357	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:12:43+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:12:48.877912+02	nkoleevans@gmail.com
358	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:04.8173+02	nkoleevans@gmail.com
359	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:05+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:05.972224+02	nkoleevans@gmail.com
360	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:07+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:07.910893+02	nkoleevans@gmail.com
361	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:11+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:12.530533+02	nkoleevans@gmail.com
362	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:12+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:12.927097+02	nkoleevans@gmail.com
364	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:15.220786+02	nkoleevans@gmail.com
367	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:20+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:21.008248+02	nkoleevans@gmail.com
369	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:23+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:23.836963+02	nkoleevans@gmail.com
372	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:25+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:25.698386+02	nkoleevans@gmail.com
374	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:26+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:26.83217+02	nkoleevans@gmail.com
363	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:12+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:13.325734+02	nkoleevans@gmail.com
366	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:20.616797+02	nkoleevans@gmail.com
368	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:20+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:21.38358+02	nkoleevans@gmail.com
371	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:24+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:25.288766+02	nkoleevans@gmail.com
373	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:25+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:26.00181+02	nkoleevans@gmail.com
378	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:41:28+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:41:29.721933+02	nkoleevans@gmail.com
365	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:19+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:20.003541+02	nkoleevans@gmail.com
370	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:15:24+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:15:24.726428+02	nkoleevans@gmail.com
375	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:40:35+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:40:36.454517+02	nkoleevans@gmail.com
376	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:40:37+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:40:37.707741+02	nkoleevans@gmail.com
377	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:41:27+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:41:28.504254+02	nkoleevans@gmail.com
379	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:43:49+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:43:50.494482+02	nkoleevans@gmail.com
380	1	nkoleevans@gmail.com	67e09fed1e1e47caaf76003f2c8236d3	2026-07-23 13:43:58+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:44:02.280708+02	nkoleevans@gmail.com
381	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:44:05+02	Session	\N	\N	Start	null	{"exp": 1784808845, "jti": "fc18fe466a2443fcb7d61261ae2e75ef", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 13:44:05.7545+02	nkoleevans@gmail.com
382	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:44:07+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:44:08.11331+02	nkoleevans@gmail.com
383	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:44:08+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:44:09.141444+02	nkoleevans@gmail.com
384	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:46+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:47.2853+02	nkoleevans@gmail.com
385	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:50+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:50.615527+02	nkoleevans@gmail.com
386	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:52+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:53.454499+02	nkoleevans@gmail.com
387	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:45:54+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:45:54.719625+02	nkoleevans@gmail.com
388	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:17+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 13:46:17.700217+02	nkoleevans@gmail.com
389	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:25+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:26.458575+02	nkoleevans@gmail.com
390	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:30+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:30.922975+02	nkoleevans@gmail.com
391	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:31.877855+02	nkoleevans@gmail.com
392	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:46:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:46:35.666236+02	nkoleevans@gmail.com
393	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:02+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:02.951733+02	nkoleevans@gmail.com
394	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:07+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:08.496548+02	nkoleevans@gmail.com
395	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:09.173827+02	nkoleevans@gmail.com
396	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:10+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:11.402721+02	nkoleevans@gmail.com
397	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:15+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:16.614182+02	nkoleevans@gmail.com
398	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:19+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:19.820915+02	nkoleevans@gmail.com
399	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:21+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:22.010263+02	nkoleevans@gmail.com
400	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:24+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:24.615987+02	nkoleevans@gmail.com
401	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:25+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:25.912044+02	nkoleevans@gmail.com
402	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:35+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:35.800427+02	nkoleevans@gmail.com
403	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:36+02	Review Service	\N	\N	View - Allowed	null	null	2026-07-23 13:47:36.833167+02	nkoleevans@gmail.com
404	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:40+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:40.780431+02	nkoleevans@gmail.com
405	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:47:44+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:47:45.454645+02	nkoleevans@gmail.com
406	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:48:08+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:48:13.728205+02	nkoleevans@gmail.com
407	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:48:09+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:48:13.772795+02	nkoleevans@gmail.com
408	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:48:13+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:48:14.115572+02	nkoleevans@gmail.com
409	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:50:25+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:50:28.123366+02	nkoleevans@gmail.com
410	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:55:29+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:56:34.433031+02	nkoleevans@gmail.com
411	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:45+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:56:46.122294+02	nkoleevans@gmail.com
412	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:54+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 13:56:55.301618+02	nkoleevans@gmail.com
413	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:57+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:56:57.892995+02	nkoleevans@gmail.com
414	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:56:58+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:56:58.656762+02	nkoleevans@gmail.com
415	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:57:26+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:57:28.981428+02	nkoleevans@gmail.com
416	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:57:55+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:57:55.978559+02	nkoleevans@gmail.com
417	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:02+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:58:05.68111+02	nkoleevans@gmail.com
418	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:41+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:58:42.431638+02	nkoleevans@gmail.com
419	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:43+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 13:58:43.571737+02	nkoleevans@gmail.com
420	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:58:57+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 13:58:57.783317+02	nkoleevans@gmail.com
421	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:59:13+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 13:59:14.048668+02	nkoleevans@gmail.com
422	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 13:59:16+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 13:59:16.609008+02	nkoleevans@gmail.com
423	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:01:31+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:01:34.848037+02	nkoleevans@gmail.com
424	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:41+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:41.558319+02	nkoleevans@gmail.com
425	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:43+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:02:44.519794+02	nkoleevans@gmail.com
426	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:47+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:48.287984+02	nkoleevans@gmail.com
427	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:51+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:52.131583+02	nkoleevans@gmail.com
428	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:56+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:57.220526+02	nkoleevans@gmail.com
429	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:57+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:57.621476+02	nkoleevans@gmail.com
430	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:58+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:58.555889+02	nkoleevans@gmail.com
431	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:02:58+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:02:59.129058+02	nkoleevans@gmail.com
432	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:00+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:00.537476+02	nkoleevans@gmail.com
433	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:01+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:01.548725+02	nkoleevans@gmail.com
434	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:01+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:02.087781+02	nkoleevans@gmail.com
435	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:02.990558+02	nkoleevans@gmail.com
436	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:03:35+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:03:35.594033+02	nkoleevans@gmail.com
437	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:05:36+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:05:37.352595+02	nkoleevans@gmail.com
438	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:07:47+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:07:50.420825+02	nkoleevans@gmail.com
439	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:07:51+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:07:52.42974+02	nkoleevans@gmail.com
440	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:37+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:37.636086+02	nkoleevans@gmail.com
441	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:37+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:39.240569+02	nkoleevans@gmail.com
442	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:40+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:41.446212+02	nkoleevans@gmail.com
443	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:41+02	District List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:42.013026+02	nkoleevans@gmail.com
444	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:08:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:08:47.808477+02	nkoleevans@gmail.com
445	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:10:55+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:10:55.802292+02	nkoleevans@gmail.com
446	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:11:07+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:11:13.186099+02	nkoleevans@gmail.com
447	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:11:11+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:11:13.19747+02	nkoleevans@gmail.com
448	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:11:29+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:11:31.630942+02	nkoleevans@gmail.com
449	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:12:30+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:12:33.677961+02	nkoleevans@gmail.com
450	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:13:45+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:13:51.123887+02	nkoleevans@gmail.com
451	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:14:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:14:23.883221+02	nkoleevans@gmail.com
452	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:16:35+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 14:16:37.357051+02	nkoleevans@gmail.com
453	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:17:04+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-23 14:17:04.850343+02	nkoleevans@gmail.com
454	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:17:06+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 14:17:07.323561+02	nkoleevans@gmail.com
455	1	nkoleevans@gmail.com	fc18fe466a2443fcb7d61261ae2e75ef	2026-07-23 14:17:17+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-23 14:17:18.049118+02	nkoleevans@gmail.com
456	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:19:43+02	Session	\N	\N	Start	null	{"exp": 1784810983, "jti": "c49e6b4d50fe41359c63f6f6317459c6", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 14:19:44.538016+02	nkoleevans@gmail.com
457	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:19:45+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 14:19:46.183511+02	nkoleevans@gmail.com
458	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:42+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:42.990336+02	nkoleevans@gmail.com
459	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:43.232733+02	nkoleevans@gmail.com
460	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:49+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:49.920085+02	nkoleevans@gmail.com
461	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:56+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:20:56.665899+02	nkoleevans@gmail.com
462	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:20:59+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:00.001897+02	nkoleevans@gmail.com
463	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:21:02+02	PT Cycle Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:02.917902+02	nkoleevans@gmail.com
464	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:21:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:45.298841+02	nkoleevans@gmail.com
465	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:21:45+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:21:45.97585+02	nkoleevans@gmail.com
466	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:22:08+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:22:09.085205+02	nkoleevans@gmail.com
467	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:22:09+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:22:09.7656+02	nkoleevans@gmail.com
468	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:22:15+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:22:15.647342+02	nkoleevans@gmail.com
469	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:24+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:25.28979+02	nkoleevans@gmail.com
470	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:48+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:48.743312+02	nkoleevans@gmail.com
471	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:49+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:50.335549+02	nkoleevans@gmail.com
472	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:51+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:23:52.286269+02	nkoleevans@gmail.com
473	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:23:55+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:23:56.190198+02	nkoleevans@gmail.com
474	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:24:01+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:24:01.828173+02	nkoleevans@gmail.com
475	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:24:06+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:24:06.740805+02	nkoleevans@gmail.com
476	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:24:08+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:24:08.724072+02	nkoleevans@gmail.com
477	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:03+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:03.698604+02	nkoleevans@gmail.com
478	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:04+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:04.967162+02	nkoleevans@gmail.com
479	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:05+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:05.652677+02	nkoleevans@gmail.com
480	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:28+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:26:32.677965+02	nkoleevans@gmail.com
481	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:30+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:26:33.258289+02	nkoleevans@gmail.com
482	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:26:31+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:26:33.269835+02	nkoleevans@gmail.com
483	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:27:14+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:27:16.604143+02	nkoleevans@gmail.com
484	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:28:25+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:28:28.255099+02	nkoleevans@gmail.com
485	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:02.631927+02	nkoleevans@gmail.com
486	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:08+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:09.176099+02	nkoleevans@gmail.com
487	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:09+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:09.658836+02	nkoleevans@gmail.com
488	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:09+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:10.171713+02	nkoleevans@gmail.com
489	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:10+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:10.608273+02	nkoleevans@gmail.com
490	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:15+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:15.93871+02	nkoleevans@gmail.com
491	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:19.178983+02	nkoleevans@gmail.com
492	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:21+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:23.093005+02	nkoleevans@gmail.com
493	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:23.654939+02	nkoleevans@gmail.com
494	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:25+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:26.11712+02	nkoleevans@gmail.com
495	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:33+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:34.18632+02	nkoleevans@gmail.com
496	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:35+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:36.203235+02	nkoleevans@gmail.com
497	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:36+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:29:37.103521+02	nkoleevans@gmail.com
498	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:46.620381+02	nkoleevans@gmail.com
499	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:29:46+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:29:47.227399+02	nkoleevans@gmail.com
500	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:50+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:51.021915+02	nkoleevans@gmail.com
501	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:51+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:51.646434+02	nkoleevans@gmail.com
502	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:52.558075+02	nkoleevans@gmail.com
503	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:55+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:30:56.343674+02	nkoleevans@gmail.com
504	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:30:59+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:30:59.902047+02	nkoleevans@gmail.com
505	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:19+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:19.8014+02	nkoleevans@gmail.com
508	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:22+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:23.191197+02	nkoleevans@gmail.com
511	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:25+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:25.624989+02	nkoleevans@gmail.com
513	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:26+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:27.479747+02	nkoleevans@gmail.com
515	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:28.952027+02	nkoleevans@gmail.com
506	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:19+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:20.416663+02	nkoleevans@gmail.com
507	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:22+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:22.751513+02	nkoleevans@gmail.com
509	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:23+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:23.563311+02	nkoleevans@gmail.com
510	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:23+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:23.84959+02	nkoleevans@gmail.com
512	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:25+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:26.259909+02	nkoleevans@gmail.com
514	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:27+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:28.142768+02	nkoleevans@gmail.com
516	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:29+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:31:29.846506+02	nkoleevans@gmail.com
517	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:31:31+02	PT Cycle Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:31:32.467752+02	nkoleevans@gmail.com
518	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:29.352777+02	nkoleevans@gmail.com
519	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:39+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:40.029007+02	nkoleevans@gmail.com
520	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:42+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:42.612989+02	nkoleevans@gmail.com
521	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:43+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:43.861718+02	nkoleevans@gmail.com
522	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:44+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:44.820909+02	nkoleevans@gmail.com
523	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:44+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:45.493607+02	nkoleevans@gmail.com
524	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:45+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:45.95484+02	nkoleevans@gmail.com
525	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:46+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:46.758482+02	nkoleevans@gmail.com
526	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:46+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:47.559409+02	nkoleevans@gmail.com
527	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:47+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:48.401601+02	nkoleevans@gmail.com
528	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:32:48+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:32:49.012714+02	nkoleevans@gmail.com
529	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:36:10+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 14:36:10.948989+02	nkoleevans@gmail.com
530	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:36:14+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:36:14.891547+02	nkoleevans@gmail.com
531	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:36:15+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 14:36:15.816513+02	nkoleevans@gmail.com
532	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:15+02	Method	\N	\N	View - Allowed	null	null	2026-07-23 14:38:18.190389+02	nkoleevans@gmail.com
533	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:18+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:19.334346+02	nkoleevans@gmail.com
534	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:20+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:38:21.005521+02	nkoleevans@gmail.com
535	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:35+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:35.915653+02	nkoleevans@gmail.com
536	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:37+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:38.363121+02	nkoleevans@gmail.com
537	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:40+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:40.987744+02	nkoleevans@gmail.com
538	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:38:42+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:38:42.807466+02	nkoleevans@gmail.com
539	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:34+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:40:36.922016+02	nkoleevans@gmail.com
540	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:36+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:40:37.034467+02	nkoleevans@gmail.com
541	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:38+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:40:38.665057+02	nkoleevans@gmail.com
542	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:40:53+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:40:56.090627+02	nkoleevans@gmail.com
543	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:41:26+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:41:29.420743+02	nkoleevans@gmail.com
544	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:41:46+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:41:49.564983+02	nkoleevans@gmail.com
545	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:42:36+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:42:37.13291+02	nkoleevans@gmail.com
546	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:42:40+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:42:40.97945+02	nkoleevans@gmail.com
547	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:42:56+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:42:56.727364+02	nkoleevans@gmail.com
548	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:12+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:12.549537+02	nkoleevans@gmail.com
549	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:13+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:13.572706+02	nkoleevans@gmail.com
550	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:15+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:15.655479+02	nkoleevans@gmail.com
551	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:16+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:17.310802+02	nkoleevans@gmail.com
552	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:17+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:17.688202+02	nkoleevans@gmail.com
553	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:17+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:18.020123+02	nkoleevans@gmail.com
554	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:17+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:18.487804+02	nkoleevans@gmail.com
556	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:46:21+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 14:46:22.521116+02	nkoleevans@gmail.com
559	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:49:39+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:49:39.767173+02	nkoleevans@gmail.com
560	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:50:26+02	Lab Type	\N	\N	View - Allowed	null	null	2026-07-23 14:50:26.970633+02	nkoleevans@gmail.com
562	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:50:41+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:50:41.80763+02	nkoleevans@gmail.com
563	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:00+02	Review PT Cycle Status	\N	\N	View - Allowed	null	null	2026-07-23 14:51:01.024126+02	nkoleevans@gmail.com
565	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:30+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:31.500345+02	nkoleevans@gmail.com
567	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:50+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:51.520215+02	nkoleevans@gmail.com
569	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:52:05.470739+02	nkoleevans@gmail.com
570	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:12+02	Scheme	\N	\N	View - Allowed	null	null	2026-07-23 14:52:13.351072+02	nkoleevans@gmail.com
571	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:20+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 14:52:20.755793+02	nkoleevans@gmail.com
574	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:01+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:53:01.925663+02	nkoleevans@gmail.com
578	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:54:58+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:54:58.562436+02	nkoleevans@gmail.com
579	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:02+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:55:03.198688+02	nkoleevans@gmail.com
581	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:55:22.034518+02	nkoleevans@gmail.com
582	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:26+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 14:55:26.783989+02	nkoleevans@gmail.com
583	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 14:55:55.480343+02	nkoleevans@gmail.com
585	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:58:29+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:58:29.765653+02	nkoleevans@gmail.com
586	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:58:30+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 14:58:31.395796+02	nkoleevans@gmail.com
589	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:09:18+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-23 15:09:18.806478+02	nkoleevans@gmail.com
591	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:14+02	Users	\N	\N	View - Allowed	null	null	2026-07-23 15:15:15.307939+02	nkoleevans@gmail.com
592	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:16+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:18.05218+02	nkoleevans@gmail.com
594	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:20+02	Statuses	\N	\N	View - Allowed	null	null	2026-07-23 15:15:20.571932+02	nkoleevans@gmail.com
596	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:21+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:21.97893+02	nkoleevans@gmail.com
597	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:24+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:25.522653+02	nkoleevans@gmail.com
598	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:25+02	District List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:25.79136+02	nkoleevans@gmail.com
600	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:28+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:29.260436+02	nkoleevans@gmail.com
602	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:30+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:30.736355+02	nkoleevans@gmail.com
604	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:32+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:33.716152+02	nkoleevans@gmail.com
605	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:33+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:34.255675+02	nkoleevans@gmail.com
607	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:35+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:36.150317+02	nkoleevans@gmail.com
609	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:41+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:41.822542+02	nkoleevans@gmail.com
611	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:43+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:45.464645+02	nkoleevans@gmail.com
613	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:18+02	Session	\N	\N	Start	null	{"exp": 1784842158, "jti": "6ebf7e0cc13e4e96ad5b6d1e85804b96", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 22:59:19.186515+02	nkoleevans@gmail.com
615	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:27.652857+02	nkoleevans@gmail.com
616	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:34+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 22:59:35.194257+02	nkoleevans@gmail.com
618	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:41+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:42.548062+02	nkoleevans@gmail.com
620	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:45.49218+02	nkoleevans@gmail.com
621	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:57+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 22:59:57.658782+02	nkoleevans@gmail.com
555	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:43:19+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:43:20.47205+02	nkoleevans@gmail.com
557	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:48:59+02	Users	\N	\N	View - Allowed	null	null	2026-07-23 14:48:59.975741+02	nkoleevans@gmail.com
558	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:49:05+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 14:49:06.023837+02	nkoleevans@gmail.com
561	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:50:34+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 14:50:35.337097+02	nkoleevans@gmail.com
564	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:04+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:05.354273+02	nkoleevans@gmail.com
566	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:33+02	District List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:34.238115+02	nkoleevans@gmail.com
568	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:51:56+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 14:51:57.272907+02	nkoleevans@gmail.com
572	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:44+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 14:52:45.48528+02	nkoleevans@gmail.com
573	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:52:54+02	Service	\N	\N	View - Allowed	null	null	2026-07-23 14:52:54.900814+02	nkoleevans@gmail.com
575	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:06+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:53:07.289938+02	nkoleevans@gmail.com
576	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:24+02	Method Sample	\N	\N	View - Allowed	null	null	2026-07-23 14:53:24.72862+02	nkoleevans@gmail.com
577	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:53:54+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 14:53:55.034867+02	nkoleevans@gmail.com
580	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:55:09+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 14:55:10.381572+02	nkoleevans@gmail.com
584	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 14:56:32+02	Province List	\N	\N	View - Allowed	null	null	2026-07-23 14:56:33.18335+02	nkoleevans@gmail.com
587	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:03:35+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 15:03:36.018967+02	nkoleevans@gmail.com
588	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:03:38+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 15:03:38.856009+02	nkoleevans@gmail.com
590	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:09:21+02	Role List	\N	\N	View - Allowed	null	null	2026-07-23 15:09:22.511164+02	nkoleevans@gmail.com
593	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:19+02	Review Stages	\N	\N	View - Allowed	null	null	2026-07-23 15:15:19.965665+02	nkoleevans@gmail.com
595	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:20+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:21.381854+02	nkoleevans@gmail.com
599	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:27+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:28.520712+02	nkoleevans@gmail.com
601	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:29+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:30.106715+02	nkoleevans@gmail.com
603	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:30+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:31.269114+02	nkoleevans@gmail.com
606	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:34+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:35.385581+02	nkoleevans@gmail.com
608	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:40+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:41.082265+02	nkoleevans@gmail.com
610	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:42.69919+02	nkoleevans@gmail.com
612	1	nkoleevans@gmail.com	c49e6b4d50fe41359c63f6f6317459c6	2026-07-23 15:15:45+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-23 15:15:47.342716+02	nkoleevans@gmail.com
614	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:21.897107+02	nkoleevans@gmail.com
617	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:40+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:41.03574+02	nkoleevans@gmail.com
619	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 22:59:42+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 22:59:43.09537+02	nkoleevans@gmail.com
622	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:01.541349+02	nkoleevans@gmail.com
623	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:02+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-23 23:00:02.911176+02	nkoleevans@gmail.com
624	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:08+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:09.366398+02	nkoleevans@gmail.com
625	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:10+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:00:10.8263+02	nkoleevans@gmail.com
626	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:14.913223+02	nkoleevans@gmail.com
627	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:15+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:00:16.090295+02	nkoleevans@gmail.com
628	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:00:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:00:19.361368+02	nkoleevans@gmail.com
629	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:15+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:16.097143+02	nkoleevans@gmail.com
630	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:17+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:17.973281+02	nkoleevans@gmail.com
631	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:22+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:23.235757+02	nkoleevans@gmail.com
632	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:25+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:25.98835+02	nkoleevans@gmail.com
633	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:27+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:27.840475+02	nkoleevans@gmail.com
634	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:30+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:30.987322+02	nkoleevans@gmail.com
635	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:07:32+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:07:33.742686+02	nkoleevans@gmail.com
637	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:17+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:10:17.588604+02	nkoleevans@gmail.com
638	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:18+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:10:18.620759+02	nkoleevans@gmail.com
640	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:25+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:10:26.108673+02	nkoleevans@gmail.com
636	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:14+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-23 23:10:15.033515+02	nkoleevans@gmail.com
639	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:10:23+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-23 23:10:24.520066+02	nkoleevans@gmail.com
641	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:11:52+02	PT Cycle Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:11:52.822521+02	nkoleevans@gmail.com
642	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:14:27+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:14:28.031627+02	nkoleevans@gmail.com
643	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:14:57+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:14:58.367618+02	nkoleevans@gmail.com
644	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:15:03+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:15:03.673483+02	nkoleevans@gmail.com
645	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:15:05+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:15:06.090851+02	nkoleevans@gmail.com
646	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:16:28+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:16:29.230741+02	nkoleevans@gmail.com
647	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:16:30+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:16:31.311284+02	nkoleevans@gmail.com
648	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:24+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:24.57776+02	nkoleevans@gmail.com
649	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:39+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:39.821353+02	nkoleevans@gmail.com
650	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:52.532732+02	nkoleevans@gmail.com
651	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:17:53+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:17:53.532814+02	nkoleevans@gmail.com
652	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:27+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:27.691755+02	nkoleevans@gmail.com
653	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:27+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:28.42925+02	nkoleevans@gmail.com
654	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:38.776526+02	nkoleevans@gmail.com
655	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:39+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:39.594637+02	nkoleevans@gmail.com
656	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:40+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:41.532499+02	nkoleevans@gmail.com
657	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:41+02	Service List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:42.423066+02	nkoleevans@gmail.com
658	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:42+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:42.846121+02	nkoleevans@gmail.com
659	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:42+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:43.17659+02	nkoleevans@gmail.com
660	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:45.310345+02	nkoleevans@gmail.com
661	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:18:50+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:18:51.570425+02	nkoleevans@gmail.com
662	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:27+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:27.641812+02	nkoleevans@gmail.com
663	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:29+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:30.079932+02	nkoleevans@gmail.com
664	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:31+02	Method List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:32.121855+02	nkoleevans@gmail.com
665	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:40:32+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-23 23:40:32.67387+02	nkoleevans@gmail.com
666	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:06+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:08.325204+02	nkoleevans@gmail.com
667	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:08+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:08.8789+02	nkoleevans@gmail.com
668	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:09+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:10.886642+02	nkoleevans@gmail.com
669	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:10+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:11.869536+02	nkoleevans@gmail.com
670	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:45:16+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:45:17.047287+02	nkoleevans@gmail.com
671	1	nkoleevans@gmail.com	6ebf7e0cc13e4e96ad5b6d1e85804b96	2026-07-23 23:47:05+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:47:06.180669+02	nkoleevans@gmail.com
672	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:47:14+02	Session	\N	\N	Start	null	{"exp": 1784845034, "jti": "334a970bf1ae4b3a8a25870143064c4f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-23 23:47:14.964078+02	nkoleevans@gmail.com
673	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:47:15+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:47:16.662003+02	nkoleevans@gmail.com
674	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:47:16+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:47:17.51685+02	nkoleevans@gmail.com
675	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:48:55+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:48:59.687259+02	nkoleevans@gmail.com
676	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:49:13+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:49:16.431094+02	nkoleevans@gmail.com
677	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:49:30+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:49:31.296131+02	nkoleevans@gmail.com
678	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:52:31+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:52:33.482829+02	nkoleevans@gmail.com
679	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:53:26.060326+02	nkoleevans@gmail.com
680	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:30+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:53:31.060101+02	nkoleevans@gmail.com
681	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:34+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:53:35.228822+02	nkoleevans@gmail.com
682	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:35+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-23 23:53:36.293308+02	nkoleevans@gmail.com
683	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:53:43+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-23 23:53:44.342381+02	nkoleevans@gmail.com
684	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 23:56:49+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-23 23:56:49.886179+02	nkoleevans@gmail.com
685	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:08:24+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:08:25.735303+02	nkoleevans@gmail.com
686	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:11:05+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:11:08.583347+02	nkoleevans@gmail.com
687	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:11:20+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:11:23.379743+02	nkoleevans@gmail.com
688	1	nkoleevans@gmail.com	334a970bf1ae4b3a8a25870143064c4f	2026-07-23 00:15:51+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:15:53.948025+02	nkoleevans@gmail.com
689	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:19:55+02	Session	\N	\N	Start	null	{"exp": 1784846995, "jti": "f8698ebe653a45e1810ab85a0713055d", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 00:19:55.972521+02	nkoleevans@gmail.com
690	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:19:57+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:19:58.192072+02	nkoleevans@gmail.com
691	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:20:00+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:20:00.665548+02	nkoleevans@gmail.com
692	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:20:31+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:20:34.17527+02	nkoleevans@gmail.com
693	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:23:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:23:18.811594+02	nkoleevans@gmail.com
694	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:23:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:23:26.107772+02	nkoleevans@gmail.com
695	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:26:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:26:14.898328+02	nkoleevans@gmail.com
696	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:26:39+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:26:39.602586+02	nkoleevans@gmail.com
697	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:49+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:51.204911+02	nkoleevans@gmail.com
698	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:53.032606+02	nkoleevans@gmail.com
699	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:53+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:53.986704+02	nkoleevans@gmail.com
700	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:29:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:29:55.446189+02	nkoleevans@gmail.com
701	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:30:41+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:30:41.817817+02	nkoleevans@gmail.com
702	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:31:21+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:31:25.34631+02	nkoleevans@gmail.com
703	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:20+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:26.064604+02	nkoleevans@gmail.com
704	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:22+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:28.01318+02	nkoleevans@gmail.com
705	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:28+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:30.463447+02	nkoleevans@gmail.com
706	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:33+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:34.0075+02	nkoleevans@gmail.com
707	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:32:47+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:32:49.013927+02	nkoleevans@gmail.com
708	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:33:02+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:33:03.110272+02	nkoleevans@gmail.com
709	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:34:39+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:34:41.100134+02	nkoleevans@gmail.com
710	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:35:02+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:35:04.821282+02	nkoleevans@gmail.com
711	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:35:08+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 00:35:08.612488+02	nkoleevans@gmail.com
712	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:35:10+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:35:10.757591+02	nkoleevans@gmail.com
713	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:09+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 00:36:11.458659+02	nkoleevans@gmail.com
714	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:30+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:30.926471+02	nkoleevans@gmail.com
715	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:41+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:41.577645+02	nkoleevans@gmail.com
716	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:45.057348+02	nkoleevans@gmail.com
717	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:36:55+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:36:55.565076+02	nkoleevans@gmail.com
718	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:38:46+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:38:48.125408+02	nkoleevans@gmail.com
719	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:38:57+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:38:57.761081+02	nkoleevans@gmail.com
720	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:39:59+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:39:59.722624+02	nkoleevans@gmail.com
721	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:40:05+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:40:07.822269+02	nkoleevans@gmail.com
722	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:40:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:40:23.859914+02	nkoleevans@gmail.com
723	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:41:11+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:41:12.506248+02	nkoleevans@gmail.com
724	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:41:12+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:41:13.268309+02	nkoleevans@gmail.com
725	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:41:50+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:41:53.29571+02	nkoleevans@gmail.com
726	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:45:22+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:45:24.709337+02	nkoleevans@gmail.com
727	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:48:58+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:49:01.314948+02	nkoleevans@gmail.com
728	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:01+02	Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 00:49:01.759743+02	nkoleevans@gmail.com
729	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:34+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:35.072495+02	nkoleevans@gmail.com
730	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:49+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:50.055368+02	nkoleevans@gmail.com
731	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:52+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:52.688818+02	nkoleevans@gmail.com
732	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:49:56+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:49:57.29206+02	nkoleevans@gmail.com
733	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:09+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:13.752739+02	nkoleevans@gmail.com
734	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:18+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:50:19.024592+02	nkoleevans@gmail.com
735	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:22+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:22.607141+02	nkoleevans@gmail.com
736	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:24.509571+02	nkoleevans@gmail.com
737	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:26+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:27.214357+02	nkoleevans@gmail.com
738	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:50:46+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:50:46.80183+02	nkoleevans@gmail.com
739	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:51:05+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:51:05.848107+02	nkoleevans@gmail.com
740	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:53:29+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:53:29.663382+02	nkoleevans@gmail.com
741	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:53:43+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:53:44.141969+02	nkoleevans@gmail.com
742	1	nkoleevans@gmail.com	f8698ebe653a45e1810ab85a0713055d	2026-07-23 00:53:44+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:53:45.21428+02	nkoleevans@gmail.com
743	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:56:42+02	Session	\N	\N	Start	null	{"exp": 1784849202, "jti": "974379f73e784c05a5cf8b1dccd5bd9a", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 00:56:43.009426+02	nkoleevans@gmail.com
744	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:56:45+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 00:56:46.018925+02	nkoleevans@gmail.com
745	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:56:46+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:56:47.438451+02	nkoleevans@gmail.com
746	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:57:02+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:57:05.506959+02	nkoleevans@gmail.com
747	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:58:20+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:58:22.951519+02	nkoleevans@gmail.com
748	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:58:49+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:58:52.070373+02	nkoleevans@gmail.com
749	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:59:13+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 00:59:16.229471+02	nkoleevans@gmail.com
750	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:59:35+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 00:59:35.86173+02	nkoleevans@gmail.com
751	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 00:59:36+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 00:59:37.30454+02	nkoleevans@gmail.com
752	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:07+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:00:08.249914+02	nkoleevans@gmail.com
753	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:10+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 01:00:10.614812+02	nkoleevans@gmail.com
754	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:58+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:00:58.609406+02	nkoleevans@gmail.com
755	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:00:59.827285+02	nkoleevans@gmail.com
756	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:00:59+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:00.365728+02	nkoleevans@gmail.com
757	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:00+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:01.85116+02	nkoleevans@gmail.com
758	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:02+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 01:01:02.802063+02	nkoleevans@gmail.com
759	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:06+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:07.352491+02	nkoleevans@gmail.com
760	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:07+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:07.946364+02	nkoleevans@gmail.com
761	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:08+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:09.136378+02	nkoleevans@gmail.com
762	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:09+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:11.854543+02	nkoleevans@gmail.com
764	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:34+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:34.884062+02	nkoleevans@gmail.com
765	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:36+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:01:37.371882+02	nkoleevans@gmail.com
763	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:01:13+02	Role List	\N	\N	View - Allowed	null	null	2026-07-24 01:01:14.454759+02	nkoleevans@gmail.com
766	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:06:36+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:06:37.410273+02	nkoleevans@gmail.com
767	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:06:44+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:06:45.03256+02	nkoleevans@gmail.com
768	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:06:45+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:06:46.179852+02	nkoleevans@gmail.com
769	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:07:35+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:07:37.256329+02	nkoleevans@gmail.com
770	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:19+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:20.342131+02	nkoleevans@gmail.com
771	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:23+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:24.346216+02	nkoleevans@gmail.com
772	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:38+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:39.497718+02	nkoleevans@gmail.com
773	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:08:40+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:08:40.605576+02	nkoleevans@gmail.com
774	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:03+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 01:09:06.363439+02	nkoleevans@gmail.com
775	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:04+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:09:06.490282+02	nkoleevans@gmail.com
776	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:09+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 01:09:09.748008+02	nkoleevans@gmail.com
777	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:09:16.81887+02	nkoleevans@gmail.com
778	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:09:18+02	Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:09:18.642829+02	nkoleevans@gmail.com
779	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:41+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:41.63214+02	nkoleevans@gmail.com
780	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:45+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:45.915795+02	nkoleevans@gmail.com
781	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:51+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:51.533842+02	nkoleevans@gmail.com
782	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:51+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:10:52.319933+02	nkoleevans@gmail.com
783	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:10:52+02	Application	\N	\N	View - Allowed	null	null	2026-07-24 01:10:53.343139+02	nkoleevans@gmail.com
784	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:14+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:15.11956+02	nkoleevans@gmail.com
785	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:29+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:30.539182+02	nkoleevans@gmail.com
786	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:31+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:32.3098+02	nkoleevans@gmail.com
787	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:55+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:55.830608+02	nkoleevans@gmail.com
788	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:11:57+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 01:11:58.068387+02	nkoleevans@gmail.com
789	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:04+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:12:05.208254+02	nkoleevans@gmail.com
790	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:08+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 01:12:09.521107+02	nkoleevans@gmail.com
791	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 01:12:15.088484+02	nkoleevans@gmail.com
792	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:16+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 01:12:16.614308+02	nkoleevans@gmail.com
793	1	nkoleevans@gmail.com	974379f73e784c05a5cf8b1dccd5bd9a	2026-07-23 01:12:19+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-07-24 01:12:19.733218+02	nkoleevans@gmail.com
794	1	nkoleevans@gmail.com	12d5371a62d542b4a798af4648958694	2026-07-23 01:53:02+02	Session	\N	\N	Start	null	{"exp": 1784852582, "jti": "12d5371a62d542b4a798af4648958694", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 01:53:03.052619+02	nkoleevans@gmail.com
795	1	nkoleevans@gmail.com	12d5371a62d542b4a798af4648958694	2026-07-23 01:53:05+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:53:05.547596+02	nkoleevans@gmail.com
796	1	nkoleevans@gmail.com	12d5371a62d542b4a798af4648958694	2026-07-23 01:53:08+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:53:09.270624+02	nkoleevans@gmail.com
797	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:53:38+02	Session	\N	\N	Start	null	{"exp": 1784852618, "jti": "7323260c182741948bebfbbd0f187e96", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 01:53:39.07226+02	nkoleevans@gmail.com
798	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:53:42+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 01:53:43.506917+02	nkoleevans@gmail.com
799	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:54:41+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 01:54:41.789197+02	nkoleevans@gmail.com
800	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-23 01:58:11+02	Role List	\N	\N	View - Allowed	null	null	2026-07-24 01:58:11.77694+02	nkoleevans@gmail.com
801	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-24 02:04:40+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 02:04:41.535223+02	nkoleevans@gmail.com
802	1	nkoleevans@gmail.com	7323260c182741948bebfbbd0f187e96	2026-07-24 02:04:44+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 02:04:45.186213+02	nkoleevans@gmail.com
803	0	nkoleevans@hotmail.com	public	2026-07-24 02:04:59+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-24 02:05:00.399155+02	nkoleevans@hotmail.com
805	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:45+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 02:05:46.216808+02	nkoleevans@hotmail.com
804	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:43+02	Session	\N	\N	Start	null	{"exp": 1784853343, "jti": "f8a4355ac56b42af8950fd7d5b84165d", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:05:44.202375+02	nkoleevans@hotmail.com
807	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:51+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 02:05:51.775221+02	nkoleevans@hotmail.com
806	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:05:46+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 02:05:47.473978+02	nkoleevans@hotmail.com
808	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:06:00+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:06:01.071165+02	nkoleevans@hotmail.com
809	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:06:12+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:06:13.33196+02	nkoleevans@hotmail.com
810	2	nkoleevans@hotmail.com	f8a4355ac56b42af8950fd7d5b84165d	2026-07-24 02:06:45+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:06:45.603676+02	nkoleevans@hotmail.com
811	3	jane@gmail.com	38eb77c6f8b3429aa6a911d01b8376ac	2026-07-24 02:07:02+02	Session	\N	\N	Start	null	{"exp": 1784853422, "jti": "38eb77c6f8b3429aa6a911d01b8376ac", "sub": "jane@gmail.com", "name": "Jane Banda", "role": 9, "mobile": "0977123456", "userid": 3}	2026-07-24 02:07:03.227438+02	jane@gmail.com
812	2	nkoleevans@hotmail.com	c3bfea11f99f4a798a324ea1fd0ba02d	2026-07-24 02:07:50+02	Session	\N	\N	Start	null	{"exp": 1784853470, "jti": "c3bfea11f99f4a798a324ea1fd0ba02d", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:07:51.485761+02	nkoleevans@hotmail.com
813	2	nkoleevans@hotmail.com	c3bfea11f99f4a798a324ea1fd0ba02d	2026-07-24 02:07:53+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 02:07:54.409148+02	nkoleevans@hotmail.com
814	2	nkoleevans@hotmail.com	1853506344c744739a34067da13c8dd7	2026-07-24 02:48:00+02	Session	\N	\N	Start	null	{"exp": 1784855880, "jti": "1853506344c744739a34067da13c8dd7", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:48:01.011418+02	nkoleevans@hotmail.com
815	2	nkoleevans@hotmail.com	9413316212fd479eb1e6ab026780b660	2026-07-24 02:48:34+02	Session	\N	\N	Start	null	{"exp": 1784855914, "jti": "9413316212fd479eb1e6ab026780b660", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 02:48:35.416541+02	nkoleevans@hotmail.com
816	2	nkoleevans@hotmail.com	9413316212fd479eb1e6ab026780b660	2026-07-24 02:48:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-24 02:48:38.848633+02	nkoleevans@hotmail.com
817	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:15:46+02	Session	\N	\N	Start	null	{"exp": 1784857546, "jti": "f23646357e0f41b2b273709c4aaebc62", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 03:15:46.923132+02	nkoleevans@hotmail.com
818	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:15:51+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 03:15:51.60923+02	nkoleevans@hotmail.com
819	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:15:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:00.21306+02	nkoleevans@hotmail.com
820	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:16:01+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:02.514563+02	nkoleevans@hotmail.com
821	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:16:41+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:42.001245+02	nkoleevans@hotmail.com
822	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:16:46+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 03:16:46.933057+02	nkoleevans@hotmail.com
823	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:18+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:18.869596+02	nkoleevans@hotmail.com
824	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:27+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:27.656846+02	nkoleevans@hotmail.com
825	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:27+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:28.262472+02	nkoleevans@hotmail.com
826	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:28+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:29.315856+02	nkoleevans@hotmail.com
827	2	nkoleevans@hotmail.com	f23646357e0f41b2b273709c4aaebc62	2026-07-24 03:17:30+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 03:17:31.052572+02	nkoleevans@hotmail.com
828	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:29:13+02	Session	\N	\N	Start	null	{"exp": 1784876353, "jti": "5f9ad37cc8a54b7e8075de735a106b80", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 08:29:14.050256+02	nkoleevans@hotmail.com
829	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:29:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:29:16.807494+02	nkoleevans@hotmail.com
830	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:29:37+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:29:38.193249+02	nkoleevans@hotmail.com
831	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:30:42+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:30:43.497636+02	nkoleevans@hotmail.com
832	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:30:47+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:30:48.033146+02	nkoleevans@hotmail.com
833	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:32:50+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:32:51.451362+02	nkoleevans@hotmail.com
834	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:32:59+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:00.470672+02	nkoleevans@hotmail.com
835	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:01+02	Method List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:01.766813+02	nkoleevans@hotmail.com
836	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:09+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:10.407003+02	nkoleevans@hotmail.com
837	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:12.223347+02	nkoleevans@hotmail.com
838	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:12+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:12.968817+02	nkoleevans@hotmail.com
839	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:33:16+02	Application List	\N	\N	View - Allowed	null	null	2026-07-24 08:33:17.182232+02	nkoleevans@hotmail.com
840	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:34:39+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:34:40.027901+02	nkoleevans@hotmail.com
841	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:34:41+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:34:41.664643+02	nkoleevans@hotmail.com
842	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:35:45+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:35:46.245464+02	nkoleevans@hotmail.com
843	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:36:58+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:36:58.876299+02	nkoleevans@hotmail.com
846	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:37:46+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:37:46.894921+02	nkoleevans@hotmail.com
847	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:38:16+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:38:17.222595+02	nkoleevans@hotmail.com
848	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:38:20+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 08:38:20.714874+02	nkoleevans@hotmail.com
849	4	markdoe@gmail.com	a155d0f74a364953b37c9e7b8a5b8c92	2026-07-24 08:38:30+02	Session	\N	\N	Start	null	{"exp": 1784876910, "jti": "a155d0f74a364953b37c9e7b8a5b8c92", "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "0977123457", "userid": 4}	2026-07-24 08:38:31.103196+02	markdoe@gmail.com
854	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:12+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:43:12.853404+02	nkoleevans@hotmail.com
855	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:43:39.151958+02	nkoleevans@hotmail.com
863	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:48:24+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 08:48:24.701489+02	nkoleevans@gmail.com
844	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:37:38+02	Method List	\N	\N	View - Allowed	null	null	2026-07-24 08:37:38.66714+02	nkoleevans@hotmail.com
845	2	nkoleevans@hotmail.com	5f9ad37cc8a54b7e8075de735a106b80	2026-07-24 08:37:42+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:37:42.914641+02	nkoleevans@hotmail.com
850	4	markdoe@gmail.com	a155d0f74a364953b37c9e7b8a5b8c92	2026-07-24 08:42:19+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 08:42:19.724098+02	markdoe@gmail.com
857	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:43:58+02	Session	\N	\N	Start	null	{"exp": 1784877238, "jti": "baeb6d66a21d44e39e7150019246ebe6", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 08:43:58.818799+02	nkoleevans@gmail.com
858	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:44:04.466842+02	nkoleevans@gmail.com
861	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:10+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:44:11.231488+02	nkoleevans@gmail.com
851	4	markdoe@gmail.com	a155d0f74a364953b37c9e7b8a5b8c92	2026-07-24 08:42:20+02	PT Cycle List	\N	\N	View - Permission Denied	null	null	2026-07-24 08:42:20.847079+02	markdoe@gmail.com
852	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:00+02	Session	\N	\N	Start	null	{"exp": 1784877180, "jti": "0f3432a94473449c80eb5b8ff84b46fb", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 08:43:01.165544+02	nkoleevans@hotmail.com
853	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:02+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:43:03.186872+02	nkoleevans@hotmail.com
856	2	nkoleevans@hotmail.com	0f3432a94473449c80eb5b8ff84b46fb	2026-07-24 08:43:42+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:43:43.326398+02	nkoleevans@hotmail.com
859	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:05+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:44:05.572296+02	nkoleevans@gmail.com
860	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:44:09+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:44:09.878378+02	nkoleevans@gmail.com
862	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:48:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 08:48:21.537613+02	nkoleevans@gmail.com
864	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:50:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 08:50:03.983707+02	nkoleevans@gmail.com
865	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:50:05+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:50:06.077477+02	nkoleevans@gmail.com
866	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 08:53:34+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 08:53:34.644978+02	nkoleevans@gmail.com
867	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:02:48+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 09:02:48.874517+02	nkoleevans@gmail.com
868	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:13+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-07-24 09:05:17.677622+02	nkoleevans@gmail.com
869	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 09:05:43.855397+02	nkoleevans@gmail.com
870	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:45+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 09:05:45.689436+02	nkoleevans@gmail.com
871	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:48+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 09:05:49.411888+02	nkoleevans@gmail.com
872	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:05:58+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 09:05:58.690838+02	nkoleevans@gmail.com
873	1	nkoleevans@gmail.com	baeb6d66a21d44e39e7150019246ebe6	2026-07-24 09:06:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 09:06:01.706945+02	nkoleevans@gmail.com
874	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:11:31+02	Session	\N	\N	Start	null	{"exp": 1784882491, "jti": "7469a1cf7aed4611a3eb244ab58ef53f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:11:32.931221+02	nkoleevans@gmail.com
875	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:11:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:11:38.95129+02	nkoleevans@gmail.com
876	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:22:30+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 10:22:32.083761+02	nkoleevans@gmail.com
877	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:25:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:25:15.073018+02	nkoleevans@gmail.com
878	1	nkoleevans@gmail.com	7469a1cf7aed4611a3eb244ab58ef53f	2026-07-24 10:40:29+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 10:40:31.621797+02	nkoleevans@gmail.com
879	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:15+02	Session	\N	\N	Start	null	{"exp": 1784884395, "jti": "9895670d9f604e3b95b11d8837392463", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:43:16.460453+02	nkoleevans@gmail.com
880	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:22+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:43:22.727101+02	nkoleevans@gmail.com
881	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:24+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 10:43:24.78025+02	nkoleevans@gmail.com
882	1	nkoleevans@gmail.com	9895670d9f604e3b95b11d8837392463	2026-07-24 10:43:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 10:43:36.150438+02	nkoleevans@gmail.com
883	1	nkoleevans@gmail.com	9ac6ed0d5f7a495c8d065b8074e3c146	2026-07-24 10:44:18+02	Session	\N	\N	Start	null	{"exp": 1784884458, "jti": "9ac6ed0d5f7a495c8d065b8074e3c146", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:44:18.744397+02	nkoleevans@gmail.com
884	1	nkoleevans@gmail.com	9ac6ed0d5f7a495c8d065b8074e3c146	2026-07-24 10:44:31+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 10:44:31.635593+02	nkoleevans@gmail.com
885	1	nkoleevans@gmail.com	1e3d2507aa934b1dbd6772219eff11ec	2026-07-24 10:47:20+02	Session	\N	\N	Start	null	{"exp": 1784884640, "jti": "1e3d2507aa934b1dbd6772219eff11ec", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 10:47:21.210721+02	nkoleevans@gmail.com
886	1	nkoleevans@gmail.com	1e3d2507aa934b1dbd6772219eff11ec	2026-07-24 10:47:26+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 10:47:27.193263+02	nkoleevans@gmail.com
887	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:47:37+02	Session	\N	\N	Start	null	{"exp": 1784884657, "jti": "4df8825633ab48a3aab7a156d8f2c6ca", "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "0977123457", "userid": 4}	2026-07-24 10:47:38.201445+02	markdoe@gmail.com
888	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:47:40+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:47:41.54302+02	markdoe@gmail.com
889	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:51:43+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:51:43.680018+02	markdoe@gmail.com
890	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:51:44+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:51:45.117093+02	markdoe@gmail.com
891	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:51:52+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 10:51:52.884104+02	markdoe@gmail.com
892	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:52:44+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 10:52:45.189059+02	markdoe@gmail.com
893	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:53:48+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 10:53:48.835469+02	markdoe@gmail.com
894	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 10:53:51+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 10:53:52.044032+02	markdoe@gmail.com
895	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:01:10+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:01:19.086232+02	markdoe@gmail.com
896	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:17+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 11:06:20.183927+02	markdoe@gmail.com
897	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:23+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:06:23.60222+02	markdoe@gmail.com
898	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:27+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:06:28.132466+02	markdoe@gmail.com
899	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:32+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:06:33.442539+02	markdoe@gmail.com
900	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:06:36+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:06:37.336977+02	markdoe@gmail.com
901	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:17+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:08:17.603534+02	markdoe@gmail.com
902	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:20+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:08:20.771474+02	markdoe@gmail.com
903	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:24+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:08:25.440711+02	markdoe@gmail.com
904	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:25+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:08:26.461971+02	markdoe@gmail.com
905	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:35+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-07-24 11:08:35.840432+02	markdoe@gmail.com
906	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:08:38+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:08:39.133242+02	markdoe@gmail.com
907	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:16+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:09:17.223234+02	markdoe@gmail.com
908	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:23+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:09:29.309489+02	markdoe@gmail.com
909	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:33+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:09:34.231246+02	markdoe@gmail.com
910	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:09:38+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:09:38.713915+02	markdoe@gmail.com
911	4	markdoe@gmail.com	4df8825633ab48a3aab7a156d8f2c6ca	2026-07-24 11:10:00+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:01.412108+02	markdoe@gmail.com
912	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:08+02	Session	\N	\N	Start	null	{"exp": 1784886008, "jti": "7d41b2afeeab4772a6305123844c830f", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 11:10:09.489333+02	nkoleevans@gmail.com
913	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:16+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:16.817942+02	nkoleevans@gmail.com
914	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:17+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:10:18.194979+02	nkoleevans@gmail.com
915	1	nkoleevans@gmail.com	7d41b2afeeab4772a6305123844c830f	2026-07-24 11:10:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:21.90826+02	nkoleevans@gmail.com
916	4	markdoe@gmail.com	095518c4379e44eca293f32879ee7b33	2026-07-24 11:10:28+02	Session	\N	\N	Start	null	{"exp": 1784886028, "jti": "095518c4379e44eca293f32879ee7b33", "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "0977123457", "userid": 4}	2026-07-24 11:10:29.231263+02	markdoe@gmail.com
917	4	markdoe@gmail.com	095518c4379e44eca293f32879ee7b33	2026-07-24 11:10:29+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:10:30.302812+02	markdoe@gmail.com
918	4	markdoe@gmail.com	095518c4379e44eca293f32879ee7b33	2026-07-24 11:10:31+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:10:32.377736+02	markdoe@gmail.com
919	1	nkoleevans@gmail.com	f25f6c37d2c8448a837921d0c2302d45	2026-07-24 11:17:44+02	Session	\N	\N	Start	null	{"exp": 1784886463, "jti": "f25f6c37d2c8448a837921d0c2302d45", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 11:17:44.57731+02	nkoleevans@gmail.com
920	1	nkoleevans@gmail.com	f25f6c37d2c8448a837921d0c2302d45	2026-07-24 11:17:46+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:17:47.437409+02	nkoleevans@gmail.com
921	1	nkoleevans@gmail.com	068033c84a64491797f8d6ce5dcac130	2026-07-24 11:20:47+02	Session	\N	\N	Start	null	{"exp": 1784886647, "jti": "068033c84a64491797f8d6ce5dcac130", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-07-24 11:20:47.853512+02	nkoleevans@gmail.com
922	1	nkoleevans@gmail.com	068033c84a64491797f8d6ce5dcac130	2026-07-24 11:20:50+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:20:50.65659+02	nkoleevans@gmail.com
923	0	alanphiri@gmail.com	public	2026-07-24 11:21:10+02	Authentication	\N	\N	Unauthorised	null	null	2026-07-24 11:21:10.518242+02	alanphiri@gmail.com
924	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:18+02	Session	\N	\N	Start	null	{"exp": 1784886678, "jti": "821da8e4eb64471c9dd605adf7c5ce8a", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:21:19.166315+02	nkoleevans@hotmail.com
925	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:20+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:21:21.30511+02	nkoleevans@hotmail.com
926	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:22+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-07-24 11:21:22.6128+02	nkoleevans@hotmail.com
927	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:33+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-07-24 11:21:34.465166+02	nkoleevans@hotmail.com
928	2	nkoleevans@hotmail.com	821da8e4eb64471c9dd605adf7c5ce8a	2026-07-24 11:21:37+02	Users	\N	\N	View - Allowed	null	null	2026-07-24 11:21:37.671972+02	nkoleevans@hotmail.com
929	5	alanphiri@gmail.com	eec6218fda1549c4a3c21ab1e987a1bf	2026-07-24 11:21:58+02	Session	\N	\N	Start	null	{"exp": 1784886718, "jti": "eec6218fda1549c4a3c21ab1e987a1bf", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:21:59.268031+02	alanphiri@gmail.com
931	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:28+02	Session	\N	\N	Start	null	{"exp": 1784886748, "jti": "c77f51f4fe404966a3676f3cbd0b3878", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:22:29.307636+02	nkoleevans@hotmail.com
933	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:33+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:34.526279+02	nkoleevans@hotmail.com
935	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:39.256308+02	nkoleevans@hotmail.com
936	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:44+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:22:45.088816+02	nkoleevans@hotmail.com
938	5	alanphiri@gmail.com	087f4c8ac11647a2a0141c839746e206	2026-07-24 11:23:14+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:23:14.834797+02	alanphiri@gmail.com
940	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:23:30+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:23:31.096397+02	nkoleevans@hotmail.com
941	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:23:31+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:23:32.12447+02	nkoleevans@hotmail.com
942	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:25:45+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-07-24 11:25:46.52729+02	nkoleevans@hotmail.com
944	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:26:07+02	Session	\N	\N	Start	null	{"exp": 1784886967, "jti": "1863d1440abc47799eff43d441a313e6", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:26:08.016666+02	alanphiri@gmail.com
949	5	alanphiri@gmail.com	384766dd80fe41e38c0744ca50ae106f	2026-07-24 11:30:14+02	Session	\N	\N	Start	null	{"exp": 1784887214, "jti": "384766dd80fe41e38c0744ca50ae106f", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:30:14.715939+02	alanphiri@gmail.com
951	2	nkoleevans@hotmail.com	d88893ca6faf4c33a1f8c0bd2e56dc45	2026-07-24 11:31:37+02	Scheme List	\N	\N	View - Allowed	null	null	2026-07-24 11:31:40.262938+02	nkoleevans@hotmail.com
952	2	nkoleevans@hotmail.com	46d8b8107fa2404eb0bd2e57ae93129f	2026-07-27 09:38:11+02	Session	\N	\N	Start	null	{"exp": 1785139691, "jti": "46d8b8107fa2404eb0bd2e57ae93129f", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-27 09:38:12.211839+02	nkoleevans@hotmail.com
930	5	alanphiri@gmail.com	eec6218fda1549c4a3c21ab1e987a1bf	2026-07-24 11:22:08+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:08.793502+02	alanphiri@gmail.com
932	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:32+02	Provider List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:33.310074+02	nkoleevans@hotmail.com
934	2	nkoleevans@hotmail.com	c77f51f4fe404966a3676f3cbd0b3878	2026-07-24 11:22:34+02	Service List	\N	\N	View - Allowed	null	null	2026-07-24 11:22:35.252739+02	nkoleevans@hotmail.com
937	5	alanphiri@gmail.com	087f4c8ac11647a2a0141c839746e206	2026-07-24 11:23:12+02	Session	\N	\N	Start	null	{"exp": 1784886792, "jti": "087f4c8ac11647a2a0141c839746e206", "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "097765435363", "userid": 5}	2026-07-24 11:23:13.295628+02	alanphiri@gmail.com
939	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:23:28+02	Session	\N	\N	Start	null	{"exp": 1784886808, "jti": "2a42b0ef76b74b1d95e0f6ec7680b679", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:23:28.867575+02	nkoleevans@hotmail.com
943	2	nkoleevans@hotmail.com	2a42b0ef76b74b1d95e0f6ec7680b679	2026-07-24 11:25:56+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-07-24 11:25:57.102295+02	nkoleevans@hotmail.com
945	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:26:11+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:26:11.690851+02	alanphiri@gmail.com
946	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:26:27+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:26:27.761745+02	alanphiri@gmail.com
947	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:29:40+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-07-24 11:29:40.530005+02	alanphiri@gmail.com
948	5	alanphiri@gmail.com	1863d1440abc47799eff43d441a313e6	2026-07-24 11:29:42+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-07-24 11:29:42.808564+02	alanphiri@gmail.com
950	2	nkoleevans@hotmail.com	d88893ca6faf4c33a1f8c0bd2e56dc45	2026-07-24 11:30:44+02	Session	\N	\N	Start	null	{"exp": 1784887244, "jti": "d88893ca6faf4c33a1f8c0bd2e56dc45", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-24 11:30:44.988528+02	nkoleevans@hotmail.com
953	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:24:52+02	Session	\N	\N	Start	null	{"exp": 1785153292, "jti": "4350696c25c44db986e17f6b76f65657", "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 1, "mobile": "+260978989259", "userid": 2}	2026-07-27 13:24:53.416071+02	nkoleevans@hotmail.com
954	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:24:57+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:24:58.238543+02	nkoleevans@hotmail.com
955	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:25:36+02	Application List	\N	\N	View - Allowed	null	null	2026-07-27 13:25:36.756625+02	nkoleevans@hotmail.com
956	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:25:38+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:25:38.799933+02	nkoleevans@hotmail.com
957	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:26:31+02	Application List	\N	\N	View - Allowed	null	null	2026-07-27 13:26:32.015665+02	nkoleevans@hotmail.com
958	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:26:32+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:26:33.422082+02	nkoleevans@hotmail.com
959	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:28:31+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:28:32.449057+02	nkoleevans@hotmail.com
960	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:28:39+02	Meter	\N	\N	View - Allowed	null	null	2026-07-27 13:28:39.653851+02	nkoleevans@hotmail.com
961	2	nkoleevans@hotmail.com	4350696c25c44db986e17f6b76f65657	2026-07-27 13:29:27+02	Meter List	\N	\N	View - Allowed	null	null	2026-07-27 13:29:28.007518+02	nkoleevans@hotmail.com
962	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:04+02	Session	\N	\N	Start	null	{"exp": 1789129984, "jti": "fa5f961adc1046aea5b5911620014dea", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-11 14:03:05.324578+02	nkoleevans@gmail.com
963	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:07+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:07.989442+02	nkoleevans@gmail.com
964	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:08+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:09.107564+02	nkoleevans@gmail.com
965	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:09+02	Method List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:10.573639+02	nkoleevans@gmail.com
966	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:10+02	Service List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:10.831163+02	nkoleevans@gmail.com
967	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:11+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:11.629338+02	nkoleevans@gmail.com
968	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:37+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:38.332224+02	nkoleevans@gmail.com
969	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:38+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:39.229755+02	nkoleevans@gmail.com
970	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:39+02	Service List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:39.902568+02	nkoleevans@gmail.com
971	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:39+02	Method List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:40.500278+02	nkoleevans@gmail.com
972	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:40+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:40.927427+02	nkoleevans@gmail.com
973	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:41+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:42.18566+02	nkoleevans@gmail.com
974	1	nkoleevans@gmail.com	fa5f961adc1046aea5b5911620014dea	2026-09-11 14:03:43+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-11 14:03:43.607123+02	nkoleevans@gmail.com
975	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:52+02	Session	\N	\N	Start	null	{"exp": 1789401712, "jti": "fb9991aecac44c62b349b97b2f81a4b5", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 17:31:53.73807+02	nkoleevans@gmail.com
976	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:56+02	Province List	\N	\N	View - Allowed	null	null	2026-09-14 17:31:57.398778+02	nkoleevans@gmail.com
977	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:57+02	District List	\N	\N	View - Allowed	null	null	2026-09-14 17:31:57.554556+02	nkoleevans@gmail.com
978	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:31:58+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 17:32:00.614857+02	nkoleevans@gmail.com
979	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:32:40+02	Province List	\N	\N	View - Allowed	null	null	2026-09-14 17:32:41.746106+02	nkoleevans@gmail.com
981	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:34:59+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 17:35:00.000358+02	nkoleevans@gmail.com
983	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:11+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:11.570256+02	nkoleevans@gmail.com
985	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:47+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:48.227925+02	nkoleevans@gmail.com
988	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:07+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 17:37:07.726388+02	nkoleevans@gmail.com
990	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:50+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 17:37:50.697932+02	nkoleevans@gmail.com
991	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:51+02	Review Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 17:37:51.876884+02	nkoleevans@gmail.com
994	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:46:41+02	Session	\N	\N	Start	null	{"exp": 1789402601, "jti": "14e41380068344c6b4a3bc3b2f3f8b8c", "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 17:46:43.268081+02	nkoleevans@gmail.com
996	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:46:49+02	Application List	\N	\N	View - Allowed	null	null	2026-09-14 17:46:50.410635+02	nkoleevans@gmail.com
997	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:48:31+02	Role List	\N	\N	View - Allowed	null	null	2026-09-14 17:48:32.084832+02	nkoleevans@gmail.com
999	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:49:43+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 17:49:44.447969+02	nkoleevans@gmail.com
980	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:32:45+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 17:32:46.371072+02	nkoleevans@gmail.com
982	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:35:38+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 17:35:38.560412+02	nkoleevans@gmail.com
984	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:21+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:21.936023+02	nkoleevans@gmail.com
986	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:56+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 17:36:56.942189+02	nkoleevans@gmail.com
987	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:36:58+02	Review Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 17:36:59.430008+02	nkoleevans@gmail.com
989	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:37:11+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 17:37:11.698947+02	nkoleevans@gmail.com
992	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:38:20+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 17:38:21.244449+02	nkoleevans@gmail.com
993	1	nkoleevans@gmail.com	fb9991aecac44c62b349b97b2f81a4b5	2026-09-14 17:38:22+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 17:38:23.477516+02	nkoleevans@gmail.com
995	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:46:45+02	Users	\N	\N	View - Allowed	null	null	2026-09-14 17:46:45.87943+02	nkoleevans@gmail.com
998	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:48:33+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-09-14 17:48:35.475494+02	nkoleevans@gmail.com
1000	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:50:15+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 17:50:15.679215+02	nkoleevans@gmail.com
1001	1	nkoleevans@gmail.com	14e41380068344c6b4a3bc3b2f3f8b8c	2026-09-14 17:50:38+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 17:50:38.822302+02	nkoleevans@gmail.com
1002	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:04+02	Session	\N	\N	Start	null	{"exp": 1789412704, "jti": "cac8d47c787d44afa6af455484015863", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 20:35:05.323775+02	nkoleevans@gmail.com
1003	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:08+02	Province List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:09.357169+02	nkoleevans@gmail.com
1004	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:09+02	District List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:10.234755+02	nkoleevans@gmail.com
1005	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:11+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:11.978381+02	nkoleevans@gmail.com
1006	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:12+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:12.735596+02	nkoleevans@gmail.com
1007	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:13+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:13.540089+02	nkoleevans@gmail.com
1008	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:14+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:14.763628+02	nkoleevans@gmail.com
1009	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:14+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:15.363553+02	nkoleevans@gmail.com
1010	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:24+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:24.576024+02	nkoleevans@gmail.com
1011	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:28+02	Review Method	\N	\N	View - Allowed	null	null	2026-09-14 20:35:29.037193+02	nkoleevans@gmail.com
1012	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:33+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:33.943939+02	nkoleevans@gmail.com
1013	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:35+02	Review Method	\N	\N	View - Allowed	null	null	2026-09-14 20:35:35.93248+02	nkoleevans@gmail.com
1014	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:37+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:37.814281+02	nkoleevans@gmail.com
1015	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:38+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:38.634027+02	nkoleevans@gmail.com
1016	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:42+02	Review Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 20:35:43.436527+02	nkoleevans@gmail.com
1017	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:45+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:46.323035+02	nkoleevans@gmail.com
1018	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:47+02	Review Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 20:35:48.350552+02	nkoleevans@gmail.com
1019	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:49+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 20:35:49.91503+02	nkoleevans@gmail.com
1020	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:35:50+02	Method Sample	\N	\N	View - Allowed	null	null	2026-09-14 20:35:50.709909+02	nkoleevans@gmail.com
1021	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:00+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:00.938054+02	nkoleevans@gmail.com
1022	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:00+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:01.352322+02	nkoleevans@gmail.com
1023	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:01+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:02.340161+02	nkoleevans@gmail.com
1024	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:08+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:09.448456+02	nkoleevans@gmail.com
1025	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:10+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:11.106171+02	nkoleevans@gmail.com
1026	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:18+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-14 20:36:19.088036+02	nkoleevans@gmail.com
1027	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:23+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:23.815249+02	nkoleevans@gmail.com
1028	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:29+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:30.053901+02	nkoleevans@gmail.com
1029	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:31+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 20:36:32.210473+02	nkoleevans@gmail.com
1030	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:42+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:43.161551+02	nkoleevans@gmail.com
1031	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:44+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 20:36:44.677286+02	nkoleevans@gmail.com
1034	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:57+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:58.075568+02	nkoleevans@gmail.com
1036	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:37:48+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 20:37:49.518107+02	nkoleevans@gmail.com
1038	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:37:52+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-14 20:37:52.991935+02	nkoleevans@gmail.com
1041	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:38:43+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 20:38:43.995401+02	nkoleevans@gmail.com
1044	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:39:36+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 20:39:36.675549+02	nkoleevans@gmail.com
1047	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:39:44+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:39:44.57595+02	nkoleevans@gmail.com
1032	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:49+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 20:36:49.716189+02	nkoleevans@gmail.com
1033	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:36:54+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 20:36:55.183719+02	nkoleevans@gmail.com
1035	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:37:39+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-14 20:37:39.912558+02	nkoleevans@gmail.com
1037	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:37:51+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 20:37:52.10014+02	nkoleevans@gmail.com
1039	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:38:31+02	Application List	\N	\N	View - Allowed	null	null	2026-09-14 20:38:31.960806+02	nkoleevans@gmail.com
1040	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:38:36+02	Review Application	\N	\N	View - Allowed	null	null	2026-09-14 20:38:36.937906+02	nkoleevans@gmail.com
1042	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:38:46+02	Users	\N	\N	View - Allowed	null	null	2026-09-14 20:38:47.29839+02	nkoleevans@gmail.com
1043	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:38:50+02	Role List	\N	\N	View - Allowed	null	null	2026-09-14 20:38:51.16016+02	nkoleevans@gmail.com
1045	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:39:36+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 20:39:37.199119+02	nkoleevans@gmail.com
1046	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:39:37+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 20:39:37.571068+02	nkoleevans@gmail.com
1048	1	nkoleevans@gmail.com	cac8d47c787d44afa6af455484015863	2026-09-14 20:59:21+02	Method List	\N	\N	View - Allowed	null	null	2026-09-14 20:59:22.248745+02	nkoleevans@gmail.com
1049	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:32:43+02	Session	\N	\N	Start	null	{"exp": 1789416163, "jti": "cbb1cf401b8649bb9e58e4e14deb693e", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 21:32:44.028808+02	nkoleevans@gmail.com
1050	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:32:45+02	Province List	\N	\N	View - Allowed	null	null	2026-09-14 21:32:46.593957+02	nkoleevans@gmail.com
1051	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:32:46+02	District List	\N	\N	View - Allowed	null	null	2026-09-14 21:32:46.685436+02	nkoleevans@gmail.com
1052	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:32:47+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 21:32:47.650349+02	nkoleevans@gmail.com
1053	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:32:49+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 21:32:49.536938+02	nkoleevans@gmail.com
1054	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:32:50+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 21:32:50.841419+02	nkoleevans@gmail.com
1055	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:33:29+02	Provider	\N	\N	View - Allowed	null	null	2026-09-14 21:33:29.903605+02	nkoleevans@gmail.com
1056	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:33:41+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 21:33:42.367807+02	nkoleevans@gmail.com
1057	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:33:43+02	Review Provider	\N	\N	View - Allowed	null	null	2026-09-14 21:33:44.246797+02	nkoleevans@gmail.com
1058	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:33:51+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 21:33:51.89267+02	nkoleevans@gmail.com
1059	1	nkoleevans@gmail.com	cbb1cf401b8649bb9e58e4e14deb693e	2026-09-14 21:33:53+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 21:33:54.045454+02	nkoleevans@gmail.com
1060	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:18+02	Session	\N	\N	Start	null	{"exp": 1789419018, "jti": "ed97891cae514ce3ba7459e106925e1f", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 22:20:19.061654+02	nkoleevans@gmail.com
1061	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:25+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 22:20:25.849768+02	nkoleevans@gmail.com
1062	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:31+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 22:20:31.721119+02	nkoleevans@gmail.com
1063	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:32+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-14 22:20:33.23682+02	nkoleevans@gmail.com
1064	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:33+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 22:20:34.624332+02	nkoleevans@gmail.com
1065	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:34+02	Scheme	\N	\N	View - Allowed	null	null	2026-09-14 22:20:35.295271+02	nkoleevans@gmail.com
1066	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:20:54+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 22:20:55.132692+02	nkoleevans@gmail.com
1067	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:21:02+02	Scheme	\N	\N	View - Allowed	null	null	2026-09-14 22:21:02.789136+02	nkoleevans@gmail.com
1068	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:21:07+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 22:21:08.369026+02	nkoleevans@gmail.com
1069	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:22:05+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 22:22:05.99434+02	nkoleevans@gmail.com
1070	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:22:34+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 22:22:35.354312+02	nkoleevans@gmail.com
1071	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:22:42+02	Service List	\N	\N	View - Allowed	null	null	2026-09-14 22:22:43.109791+02	nkoleevans@gmail.com
1072	1	nkoleevans@gmail.com	ed97891cae514ce3ba7459e106925e1f	2026-09-14 22:22:47+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 22:22:48.163143+02	nkoleevans@gmail.com
1073	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:31:54+02	Session	\N	\N	Start	null	{"exp": 1789423314, "jti": "3a3ca993c5cb48d2a555cc24aef92b9e", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-14 23:31:55.367609+02	nkoleevans@gmail.com
1074	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:31:56+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-14 23:31:57.003663+02	nkoleevans@gmail.com
1075	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:32:36+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:32:37.437673+02	nkoleevans@gmail.com
1076	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:32:38+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:32:39.011722+02	nkoleevans@gmail.com
1117	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:02+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:02.807984+02	nkoleevans@gmail.com
1077	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:32:39+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:32:40.393676+02	nkoleevans@gmail.com
1078	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:32:40+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-14 23:32:41.446391+02	nkoleevans@gmail.com
1079	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:49:13+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-14 23:49:15.167415+02	nkoleevans@gmail.com
1080	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:54:58+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-14 23:55:01.002694+02	nkoleevans@gmail.com
1081	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:02+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-14 23:57:02.558514+02	nkoleevans@gmail.com
1082	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:43+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:43.619842+02	nkoleevans@gmail.com
1083	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:45+02	HIV-1 EID Result	\N	\N	View - Allowed	null	null	2026-09-14 23:57:46.321786+02	nkoleevans@gmail.com
1084	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:48+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:49.353665+02	nkoleevans@gmail.com
1085	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:50+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:50.632071+02	nkoleevans@gmail.com
1086	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:50+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:51.289493+02	nkoleevans@gmail.com
1087	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:53+02	Application List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:53.604521+02	nkoleevans@gmail.com
1088	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:55+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:56.302733+02	nkoleevans@gmail.com
1089	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:57:56+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 23:57:57.067125+02	nkoleevans@gmail.com
1090	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:59:34+02	Enrollment	\N	\N	View - Allowed	null	null	2026-09-14 23:59:35.313932+02	nkoleevans@gmail.com
1091	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 23:59:38+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-14 23:59:39.004521+02	nkoleevans@gmail.com
1092	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:26+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 00:00:26.698959+02	nkoleevans@gmail.com
1093	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:27+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:27.8946+02	nkoleevans@gmail.com
1094	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:41+02	Review Stages	\N	\N	View - Allowed	null	null	2026-09-15 00:00:41.64062+02	nkoleevans@gmail.com
1095	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:41+02	Statuses	\N	\N	View - Allowed	null	null	2026-09-15 00:00:42.477373+02	nkoleevans@gmail.com
1096	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:42+02	Lab Type List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:42.923776+02	nkoleevans@gmail.com
1097	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:43+02	PT Cycle Status List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:44.148635+02	nkoleevans@gmail.com
1098	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:50+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:51.48527+02	nkoleevans@gmail.com
1099	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:52+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:52.566458+02	nkoleevans@gmail.com
1100	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:53+02	Service List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:53.64418+02	nkoleevans@gmail.com
1101	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:53+02	Method List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:54.450469+02	nkoleevans@gmail.com
1102	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:00:55+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-15 00:00:55.735859+02	nkoleevans@gmail.com
1103	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:14+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:14.610593+02	nkoleevans@gmail.com
1104	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:19.464423+02	nkoleevans@gmail.com
1105	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:19+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:20.111356+02	nkoleevans@gmail.com
1106	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:21+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:21.985184+02	nkoleevans@gmail.com
1107	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:22+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:23.335752+02	nkoleevans@gmail.com
1108	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:23+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:24.084955+02	nkoleevans@gmail.com
1109	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:24+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:24.860631+02	nkoleevans@gmail.com
1110	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:25+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-15 00:01:25.915136+02	nkoleevans@gmail.com
1111	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:25+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 00:01:26.375474+02	nkoleevans@gmail.com
1112	1	nkoleevans@gmail.com	3a3ca993c5cb48d2a555cc24aef92b9e	2026-09-14 00:01:29+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 00:01:30.094061+02	nkoleevans@gmail.com
1113	1	nkoleevans@gmail.com	c7ff243736144378b39bff3ad5ff9ae6	2026-09-15 08:12:17+02	Session	\N	\N	Start	null	{"exp": 1789454537, "jti": "c7ff243736144378b39bff3ad5ff9ae6", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 08:12:18.331784+02	nkoleevans@gmail.com
1114	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:32:46+02	Session	\N	\N	Start	null	{"exp": 1789462966, "jti": "3439f7b33f9044769024e7041cfa2913", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 10:32:47.138507+02	nkoleevans@gmail.com
1115	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:35:46+02	Data Migration	\N	\N	View - Allowed	null	null	2026-09-15 10:35:47.342483+02	nkoleevans@gmail.com
1116	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:36:23+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 10:36:23.673243+02	nkoleevans@gmail.com
1118	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:08+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:08.887143+02	nkoleevans@gmail.com
1120	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:11+02	Service List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:11.900544+02	nkoleevans@gmail.com
1122	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:15+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:15.930614+02	nkoleevans@gmail.com
1124	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:24+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:25.434145+02	nkoleevans@gmail.com
1126	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:28+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:28.782312+02	nkoleevans@gmail.com
1128	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:32+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:33.398341+02	nkoleevans@gmail.com
1132	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:48:27+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:48:27.711847+02	nkoleevans@gmail.com
1133	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:48:30+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-15 10:48:30.686637+02	nkoleevans@gmail.com
1135	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:48:37+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:48:37.944531+02	nkoleevans@gmail.com
1136	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:48:38+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-15 10:48:39.523713+02	nkoleevans@gmail.com
1139	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:49:43+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:49:44.250941+02	nkoleevans@gmail.com
1142	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:50:05+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:50:06.243153+02	nkoleevans@gmail.com
1144	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:57:45+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:57:45.940351+02	nkoleevans@gmail.com
1145	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:58:13+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:58:14.226936+02	nkoleevans@gmail.com
1147	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:58:20+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:58:20.869484+02	nkoleevans@gmail.com
1148	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:05:40+02	Session	\N	\N	Start	null	{"exp": 1789464940, "jti": "2fdc255f32f04bc78564dc3ad2f0c5fb", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 11:05:40.647803+02	nkoleevans@gmail.com
1150	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:06:05+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-15 11:06:05.710398+02	nkoleevans@gmail.com
1152	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:06:50+02	Method List	\N	\N	View - Allowed	null	null	2026-09-15 11:06:51.492857+02	nkoleevans@gmail.com
1154	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:08:22+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 11:08:23.416321+02	nkoleevans@gmail.com
1155	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:09:36+02	Session	\N	\N	Start	null	{"exp": 1789465176, "jti": "388ba63c9b114e2d92909257e1cc812e", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 11:09:36.94162+02	nkoleevans@gmail.com
1157	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:09:49+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 11:09:50.35246+02	nkoleevans@gmail.com
1159	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:10:55+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 11:10:56.017831+02	nkoleevans@gmail.com
1162	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:11:41+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 11:11:41.726523+02	nkoleevans@gmail.com
1164	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:12:25+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-15 11:12:26.074779+02	nkoleevans@gmail.com
1166	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:26:30+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 11:26:31.244596+02	nkoleevans@gmail.com
1167	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:26:35+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-15 11:26:35.792729+02	nkoleevans@gmail.com
1170	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:27:46+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 11:27:47.265168+02	nkoleevans@gmail.com
1172	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:33+02	Session	\N	\N	Start	null	{"exp": 1789468833, "jti": "86b4db47b4a546c99f28f0dfb3921a23", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 12:10:34.312021+02	nkoleevans@gmail.com
1174	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:37+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:38.275418+02	nkoleevans@gmail.com
1176	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:40+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:40.888829+02	nkoleevans@gmail.com
1178	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:41+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:42.307198+02	nkoleevans@gmail.com
1180	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:51+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:51.585535+02	nkoleevans@gmail.com
1182	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:57+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:57.909497+02	nkoleevans@gmail.com
1184	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:12:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:12:44.341308+02	nkoleevans@gmail.com
1185	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:12:44+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 12:12:45.476276+02	nkoleevans@gmail.com
1186	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:22:18+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:22:19.154642+02	nkoleevans@gmail.com
1196	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:24:17+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:24:19.064124+02	nkoleevans@gmail.com
1197	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:24:19+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:24:20.371434+02	nkoleevans@gmail.com
1119	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:09+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:09.762278+02	nkoleevans@gmail.com
1121	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:13+02	Method List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:14.324645+02	nkoleevans@gmail.com
1123	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:19+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:20.062659+02	nkoleevans@gmail.com
1125	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:26.241422+02	nkoleevans@gmail.com
1127	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:31+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:31.673703+02	nkoleevans@gmail.com
1129	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:33+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:34.408803+02	nkoleevans@gmail.com
1130	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:34+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:44:35.000749+02	nkoleevans@gmail.com
1131	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:44:34+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 10:44:35.453056+02	nkoleevans@gmail.com
1134	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:48:36+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:48:36.851048+02	nkoleevans@gmail.com
1137	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:49:28+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:49:29.476629+02	nkoleevans@gmail.com
1138	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:49:30+02	HIV-1 Viral Load Result	\N	\N	View - Allowed	null	null	2026-09-15 10:49:31.398668+02	nkoleevans@gmail.com
1140	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:49:49+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:49:49.802816+02	nkoleevans@gmail.com
1141	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:49:50+02	HIV-1 EID Result	\N	\N	View - Allowed	null	null	2026-09-15 10:49:51.288753+02	nkoleevans@gmail.com
1143	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:50:20+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:50:21.113922+02	nkoleevans@gmail.com
1146	1	nkoleevans@gmail.com	3439f7b33f9044769024e7041cfa2913	2026-09-15 10:58:18+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-15 10:58:19.176895+02	nkoleevans@gmail.com
1149	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:05:51+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-15 11:05:54.373354+02	nkoleevans@gmail.com
1151	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:06:20+02	Service List	\N	\N	View - Allowed	null	null	2026-09-15 11:06:21.472174+02	nkoleevans@gmail.com
1153	1	nkoleevans@gmail.com	2fdc255f32f04bc78564dc3ad2f0c5fb	2026-09-15 11:07:40+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-15 11:07:40.591961+02	nkoleevans@gmail.com
1156	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:09:39+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 11:09:40.259093+02	nkoleevans@gmail.com
1158	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:10:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 11:10:26.262282+02	nkoleevans@gmail.com
1160	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:11:00+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 11:11:00.655923+02	nkoleevans@gmail.com
1161	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:11:17+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-15 11:11:17.970488+02	nkoleevans@gmail.com
1163	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:11:58+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 11:11:59.065599+02	nkoleevans@gmail.com
1165	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:12:40+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 11:12:40.568749+02	nkoleevans@gmail.com
1168	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:26:37+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 11:26:37.583805+02	nkoleevans@gmail.com
1169	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:26:40+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-15 11:26:41.224094+02	nkoleevans@gmail.com
1171	1	nkoleevans@gmail.com	388ba63c9b114e2d92909257e1cc812e	2026-09-15 11:29:18+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 11:29:18.897836+02	nkoleevans@gmail.com
1173	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:35+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:37.422433+02	nkoleevans@gmail.com
1175	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:39+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:40.192917+02	nkoleevans@gmail.com
1177	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:40+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:41.447819+02	nkoleevans@gmail.com
1179	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:42+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 12:10:43.273076+02	nkoleevans@gmail.com
1181	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:10:55+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-15 12:10:56.271952+02	nkoleevans@gmail.com
1183	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:12:41+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 12:12:41.568637+02	nkoleevans@gmail.com
1187	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:22:29+02	Round Evaluation	\N	\N	View - Allowed	null	null	2026-09-15 12:22:29.747963+02	nkoleevans@gmail.com
1188	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:22:46+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:22:47.402132+02	nkoleevans@gmail.com
1189	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:22:51+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 12:22:52.061567+02	nkoleevans@gmail.com
1190	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:23:06+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:23:07.170496+02	nkoleevans@gmail.com
1191	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:23:08+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 12:23:08.624227+02	nkoleevans@gmail.com
1192	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:23:11+02	Enrollment	\N	\N	View - Allowed	null	null	2026-09-15 12:23:12.088081+02	nkoleevans@gmail.com
1193	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:23:40+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 12:23:41.515287+02	nkoleevans@gmail.com
1194	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:23:48+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:23:48.5649+02	nkoleevans@gmail.com
1195	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:24:09+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:24:10.387665+02	nkoleevans@gmail.com
1198	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:26:03+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:26:04.002411+02	nkoleevans@gmail.com
1199	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:33+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:30:34.27987+02	nkoleevans@gmail.com
1200	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:46+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:30:46.70539+02	nkoleevans@gmail.com
1201	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:50+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:30:51.19828+02	nkoleevans@gmail.com
1202	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:53+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:30:53.757635+02	nkoleevans@gmail.com
1203	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:55+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:30:55.701953+02	nkoleevans@gmail.com
1204	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:56+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:30:56.946608+02	nkoleevans@gmail.com
1205	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:30:56+02	Data Migration	\N	\N	View - Allowed	null	null	2026-09-15 12:30:57.512684+02	nkoleevans@gmail.com
1206	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:31:10+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:31:11.390606+02	nkoleevans@gmail.com
1207	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:31:12+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:31:12.519327+02	nkoleevans@gmail.com
1208	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:31:18+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:31:18.544086+02	nkoleevans@gmail.com
1209	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:31:18+02	Data Migration	\N	\N	View - Allowed	null	null	2026-09-15 12:31:19.009374+02	nkoleevans@gmail.com
1210	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:31:24+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:31:25.203059+02	nkoleevans@gmail.com
1211	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:31:26+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:31:26.733152+02	nkoleevans@gmail.com
1212	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:06+02	Role List	\N	\N	View - Allowed	null	null	2026-09-15 12:32:06.968547+02	nkoleevans@gmail.com
1213	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:09+02	Data Migration	\N	\N	View - Allowed	null	null	2026-09-15 12:32:09.946915+02	nkoleevans@gmail.com
1214	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:11+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:32:11.687625+02	nkoleevans@gmail.com
1215	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:33+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:32:34.262322+02	nkoleevans@gmail.com
1216	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:43+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 12:32:43.893657+02	nkoleevans@gmail.com
1217	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:45+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:32:46.530332+02	nkoleevans@gmail.com
1218	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:47+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 12:32:48.115663+02	nkoleevans@gmail.com
1219	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:32:51+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:32:52.330637+02	nkoleevans@gmail.com
1220	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:33:04+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:33:05.168884+02	nkoleevans@gmail.com
1221	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:33:54+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:33:54.917624+02	nkoleevans@gmail.com
1222	1	nkoleevans@gmail.com	86b4db47b4a546c99f28f0dfb3921a23	2026-09-15 12:34:24+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 12:34:24.843143+02	nkoleevans@gmail.com
1223	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:00+02	Session	\N	\N	Start	null	{"exp": 1789470360, "jti": "ed496114b19647ee9dc20b08e9a814e8", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-15 12:36:00.556562+02	chanda.mwape@adch.health.zm
1224	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:04+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-15 12:36:04.531922+02	chanda.mwape@adch.health.zm
1225	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:15+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 12:36:16.358531+02	chanda.mwape@adch.health.zm
1226	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:17+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 12:36:18.195831+02	chanda.mwape@adch.health.zm
1227	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:18+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 12:36:19.25873+02	chanda.mwape@adch.health.zm
1228	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:19+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 12:36:20.248877+02	chanda.mwape@adch.health.zm
1229	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:20+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 12:36:21.260997+02	chanda.mwape@adch.health.zm
1230	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:36:25+02	HIV-1 Viral Load Result	\N	\N	View - Allowed	null	null	2026-09-15 12:36:25.832301+02	chanda.mwape@adch.health.zm
1231	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:03+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-15 12:37:04.942087+02	chanda.mwape@adch.health.zm
1232	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:09+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 12:37:10.400098+02	chanda.mwape@adch.health.zm
1233	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:29+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-15 12:37:30.460353+02	chanda.mwape@adch.health.zm
1234	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:30+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:30.676817+02	chanda.mwape@adch.health.zm
1235	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:30+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:31.360608+02	chanda.mwape@adch.health.zm
1236	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:31+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:31.803881+02	chanda.mwape@adch.health.zm
1237	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:34+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:38.042276+02	chanda.mwape@adch.health.zm
1238	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:31+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:38.18432+02	chanda.mwape@adch.health.zm
1239	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:33+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:38.192302+02	chanda.mwape@adch.health.zm
1240	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:36+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:38.254129+02	chanda.mwape@adch.health.zm
1241	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:33+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-15 12:37:38.212154+02	chanda.mwape@adch.health.zm
1242	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:37+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 12:37:38.385303+02	chanda.mwape@adch.health.zm
1243	152	chanda.mwape@adch.health.zm	ed496114b19647ee9dc20b08e9a814e8	2026-09-15 12:37:39+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-15 12:37:40.416561+02	chanda.mwape@adch.health.zm
1244	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:00+02	Session	\N	\N	Start	null	{"exp": 1789470480, "jti": "6d030eda69a3449790ec9eef27eed65e", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 12:38:00.733448+02	nkoleevans@gmail.com
1245	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:04+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:09.578447+02	nkoleevans@gmail.com
1246	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:13+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-15 12:38:14.486549+02	nkoleevans@gmail.com
1247	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:18+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:19.321263+02	nkoleevans@gmail.com
1248	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:21+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:22.182801+02	nkoleevans@gmail.com
1249	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:23+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:23.600265+02	nkoleevans@gmail.com
1250	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:27+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:28.359587+02	nkoleevans@gmail.com
1251	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:32+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:32.918114+02	nkoleevans@gmail.com
1252	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:33+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:34.39399+02	nkoleevans@gmail.com
1253	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:42+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 12:38:48.204809+02	nkoleevans@gmail.com
1254	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:53+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:38:53.564725+02	nkoleevans@gmail.com
1255	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:38:54+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 12:38:55.220558+02	nkoleevans@gmail.com
1256	1	nkoleevans@gmail.com	6d030eda69a3449790ec9eef27eed65e	2026-09-15 12:39:01+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 12:39:02.121411+02	nkoleevans@gmail.com
1257	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:07+02	Session	\N	\N	Start	null	{"exp": 1789470547, "jti": "07a49b3e01fe41f39b3e441e1d768851", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-15 12:39:07.690062+02	chanda.mwape@adch.health.zm
1258	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:08+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 12:39:09.218401+02	chanda.mwape@adch.health.zm
1259	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:10+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 12:39:11.548754+02	chanda.mwape@adch.health.zm
1260	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:11+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 12:39:12.114377+02	chanda.mwape@adch.health.zm
1261	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:12+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 12:39:12.769502+02	chanda.mwape@adch.health.zm
1262	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:12+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-15 12:39:13.365546+02	chanda.mwape@adch.health.zm
1263	152	chanda.mwape@adch.health.zm	07a49b3e01fe41f39b3e441e1d768851	2026-09-15 12:39:14+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-15 12:39:14.951852+02	chanda.mwape@adch.health.zm
1264	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:00:06+02	Session	\N	\N	Start	null	{"exp": 1789471806, "jti": "678537faff0c484cae57a742bef05129", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 13:00:07.18995+02	nkoleevans@gmail.com
1265	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:00:08+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 13:00:09.489895+02	nkoleevans@gmail.com
1266	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:00:17+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:00:17.830331+02	nkoleevans@gmail.com
1267	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:00:34+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 13:00:35.17698+02	nkoleevans@gmail.com
1268	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:03+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:01:05.597776+02	nkoleevans@gmail.com
1269	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:19+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 13:01:20.287752+02	nkoleevans@gmail.com
1270	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:31+02	View User	\N	\N	View - Allowed	null	null	2026-09-15 13:01:31.706096+02	nkoleevans@gmail.com
1271	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:37+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-15 13:01:37.788314+02	nkoleevans@gmail.com
1272	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:45+02	View User	\N	\N	View - Allowed	null	null	2026-09-15 13:01:45.87846+02	nkoleevans@gmail.com
1273	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:47+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-15 13:01:47.952985+02	nkoleevans@gmail.com
1274	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:01:52+02	View User	\N	\N	View - Allowed	null	null	2026-09-15 13:01:52.939862+02	nkoleevans@gmail.com
1275	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:11+02	Application List	\N	\N	View - Allowed	null	null	2026-09-15 13:02:12.306415+02	nkoleevans@gmail.com
1276	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:14+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 13:02:15.457549+02	nkoleevans@gmail.com
1277	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:02:23.68121+02	nkoleevans@gmail.com
1278	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:27+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 13:02:28.144322+02	nkoleevans@gmail.com
1281	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:50+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:02:51.502545+02	nkoleevans@gmail.com
1282	152	chanda.mwape@adch.health.zm	1d77cc97c51a423bb89cb6122ca29a5f	2026-09-15 13:02:58+02	Session	\N	\N	Start	null	{"exp": 1789471978, "jti": "1d77cc97c51a423bb89cb6122ca29a5f", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-15 13:02:58.629241+02	chanda.mwape@adch.health.zm
1283	152	chanda.mwape@adch.health.zm	1d77cc97c51a423bb89cb6122ca29a5f	2026-09-15 13:03:00+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-15 13:03:01.08414+02	chanda.mwape@adch.health.zm
1284	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:03:09+02	Session	\N	\N	Start	null	{"exp": 1789471989, "jti": "2d5a4d2f496e41d49c3c48938489174f", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-15 13:03:10.105832+02	nkoleevans@gmail.com
1289	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:06:26+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 13:06:27.273914+02	nkoleevans@gmail.com
1290	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:06:32+02	View User	\N	\N	View - Allowed	null	null	2026-09-15 13:06:32.897294+02	nkoleevans@gmail.com
1291	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:06:34+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-15 13:06:34.949636+02	nkoleevans@gmail.com
1293	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:08:01+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 13:08:02.056345+02	nkoleevans@gmail.com
1297	163	nkoleevans@gmail.com	df8d97379a1740d0b70a4a335b6eb128	2026-09-15 13:08:29+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 13:08:30.107328+02	nkoleevans@gmail.com
1300	163	nkoleevans@gmail.com	df8d97379a1740d0b70a4a335b6eb128	2026-09-15 13:08:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:08:45.141368+02	nkoleevans@gmail.com
1301	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:08:52+02	Session	\N	\N	Start	null	{"exp": 1789472332, "jti": "68cf02dbc587445885132d2c26a6006e", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-15 13:08:53.206841+02	chanda.mwape@adch.health.zm
1302	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:08:53+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-15 13:08:54.685171+02	chanda.mwape@adch.health.zm
1303	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:10+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:10.759317+02	chanda.mwape@adch.health.zm
1305	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:12+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:12.836921+02	chanda.mwape@adch.health.zm
1307	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:14+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:15.464954+02	chanda.mwape@adch.health.zm
1309	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:18+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-15 13:09:19.106745+02	chanda.mwape@adch.health.zm
1311	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:20+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:21.189307+02	chanda.mwape@adch.health.zm
1313	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:23+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:24.214008+02	chanda.mwape@adch.health.zm
1316	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:09:35+02	Service List	\N	\N	View - Allowed	null	null	2026-09-15 13:09:36.770936+02	nkoleevans@gmail.com
1318	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:09:37+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-15 13:09:38.809373+02	nkoleevans@gmail.com
1322	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:10:21+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 13:10:22.41545+02	nkoleevans@gmail.com
1323	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:10:32+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-15 13:10:32.714612+02	nkoleevans@gmail.com
1325	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:10:44+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:10:44.872073+02	nkoleevans@gmail.com
1326	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:10:45+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 13:10:46.360134+02	nkoleevans@gmail.com
1327	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:11:04+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:11:05.248385+02	nkoleevans@gmail.com
1328	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:16+02	Session	\N	\N	Start	null	{"exp": 1789472476, "jti": "da6f9e42588a48f6b10733383294fd5d", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-15 13:11:17.437191+02	chanda.mwape@adch.health.zm
1330	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:24+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:24.721984+02	chanda.mwape@adch.health.zm
1332	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:26+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:27.500481+02	chanda.mwape@adch.health.zm
1335	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:55+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:55.831699+02	chanda.mwape@adch.health.zm
1337	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:57+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:58.3358+02	chanda.mwape@adch.health.zm
1339	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:12:05+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:12:06.32429+02	chanda.mwape@adch.health.zm
1342	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:12:20+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 13:12:21.088142+02	chanda.mwape@adch.health.zm
1346	163	nkoleevans@gmail.com	91f64aa8464a46f78596aa59c6562fd2	2026-09-16 07:47:57+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 07:47:58.238929+02	nkoleevans@gmail.com
1348	163	nkoleevans@gmail.com	91f64aa8464a46f78596aa59c6562fd2	2026-09-16 07:48:12+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 07:48:13.345478+02	nkoleevans@gmail.com
1279	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:32+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:02:33.317063+02	nkoleevans@gmail.com
1280	1	nkoleevans@gmail.com	678537faff0c484cae57a742bef05129	2026-09-15 13:02:42+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 13:02:42.883054+02	nkoleevans@gmail.com
1285	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:03:11+02	Users	\N	\N	View - Allowed	null	null	2026-09-15 13:03:11.808032+02	nkoleevans@gmail.com
1286	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:06:09+02	View User	\N	\N	View - Allowed	null	null	2026-09-15 13:06:10.294299+02	nkoleevans@gmail.com
1287	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:06:17+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-15 13:06:18.074318+02	nkoleevans@gmail.com
1288	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:06:24+02	View User	\N	\N	View - Allowed	null	null	2026-09-15 13:06:24.546087+02	nkoleevans@gmail.com
1292	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:07:57+02	Province List	\N	\N	View - Allowed	null	null	2026-09-15 13:07:58.162141+02	nkoleevans@gmail.com
1294	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:08:05+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:08:06.823078+02	nkoleevans@gmail.com
1295	1	nkoleevans@gmail.com	2d5a4d2f496e41d49c3c48938489174f	2026-09-15 13:08:06+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 13:08:07.402522+02	nkoleevans@gmail.com
1296	163	nkoleevans@gmail.com	df8d97379a1740d0b70a4a335b6eb128	2026-09-15 13:08:24+02	Session	\N	\N	Start	null	{"exp": 1789472304, "jti": "df8d97379a1740d0b70a4a335b6eb128", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-15 13:08:25.130633+02	nkoleevans@gmail.com
1298	163	nkoleevans@gmail.com	df8d97379a1740d0b70a4a335b6eb128	2026-09-15 13:08:31+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:08:32.440381+02	nkoleevans@gmail.com
1299	163	nkoleevans@gmail.com	df8d97379a1740d0b70a4a335b6eb128	2026-09-15 13:08:32+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 13:08:33.518661+02	nkoleevans@gmail.com
1304	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:11+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:12.020805+02	chanda.mwape@adch.health.zm
1306	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:14+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:14.69734+02	chanda.mwape@adch.health.zm
1308	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:16+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-15 13:09:16.608883+02	chanda.mwape@adch.health.zm
1310	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:20+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-15 13:09:20.629831+02	chanda.mwape@adch.health.zm
1312	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:22+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:23.473353+02	chanda.mwape@adch.health.zm
1314	152	chanda.mwape@adch.health.zm	68cf02dbc587445885132d2c26a6006e	2026-09-15 13:09:24+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 13:09:25.811697+02	chanda.mwape@adch.health.zm
1315	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:09:30+02	Session	\N	\N	Start	null	{"exp": 1789472370, "jti": "b07a0d8183754379a3630df74c45da7c", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-15 13:09:31.522396+02	nkoleevans@gmail.com
1317	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:09:37+02	Method List	\N	\N	View - Allowed	null	null	2026-09-15 13:09:37.52881+02	nkoleevans@gmail.com
1319	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:09:39+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-15 13:09:41.480497+02	nkoleevans@gmail.com
1320	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:09:41+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-15 13:09:42.018932+02	nkoleevans@gmail.com
1321	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:10:18+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-15 13:10:19.598847+02	nkoleevans@gmail.com
1324	163	nkoleevans@gmail.com	b07a0d8183754379a3630df74c45da7c	2026-09-15 13:10:40+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-15 13:10:40.928684+02	nkoleevans@gmail.com
1329	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:22+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:22.933417+02	chanda.mwape@adch.health.zm
1331	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:25+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:25.923651+02	chanda.mwape@adch.health.zm
1333	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:28+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:29.248606+02	chanda.mwape@adch.health.zm
1334	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:41+02	HIV-1 Viral Load Result	\N	\N	View - Allowed	null	null	2026-09-15 13:11:42.115199+02	chanda.mwape@adch.health.zm
1336	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:11:57+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 13:11:57.709941+02	chanda.mwape@adch.health.zm
1338	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:12:05+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 13:12:05.726517+02	chanda.mwape@adch.health.zm
1340	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:12:06+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-15 13:12:07.265347+02	chanda.mwape@adch.health.zm
1341	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:12:07+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-15 13:12:07.793182+02	chanda.mwape@adch.health.zm
1343	152	chanda.mwape@adch.health.zm	da6f9e42588a48f6b10733383294fd5d	2026-09-15 13:12:21+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-15 13:12:21.777828+02	chanda.mwape@adch.health.zm
1344	152	chanda.mwape@adch.health.zm	45b9fc51fb134a87a1e929057a05ceb9	2026-09-16 07:46:41+02	Session	\N	\N	Start	null	{"exp": 1789539401, "jti": "45b9fc51fb134a87a1e929057a05ceb9", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-16 07:46:42.068972+02	chanda.mwape@adch.health.zm
1345	163	nkoleevans@gmail.com	91f64aa8464a46f78596aa59c6562fd2	2026-09-16 07:47:39+02	Session	\N	\N	Start	null	{"exp": 1789539459, "jti": "91f64aa8464a46f78596aa59c6562fd2", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 07:47:39.566135+02	nkoleevans@gmail.com
1347	163	nkoleevans@gmail.com	91f64aa8464a46f78596aa59c6562fd2	2026-09-16 07:48:09+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 07:48:10.126791+02	nkoleevans@gmail.com
1349	163	nkoleevans@gmail.com	91f64aa8464a46f78596aa59c6562fd2	2026-09-16 08:01:57+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 08:01:58.209984+02	nkoleevans@gmail.com
1350	152	chanda.mwape@adch.health.zm	e49b526220bd44c99874fb5d4dd986dc	2026-09-16 08:05:39+02	Session	\N	\N	Start	null	{"exp": 1789540539, "jti": "e49b526220bd44c99874fb5d4dd986dc", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-16 08:05:39.702458+02	chanda.mwape@adch.health.zm
1351	152	chanda.mwape@adch.health.zm	e49b526220bd44c99874fb5d4dd986dc	2026-09-16 08:05:42+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 08:05:42.672937+02	chanda.mwape@adch.health.zm
1352	152	chanda.mwape@adch.health.zm	e49b526220bd44c99874fb5d4dd986dc	2026-09-16 08:05:53+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:06:07.293663+02	chanda.mwape@adch.health.zm
1353	152	chanda.mwape@adch.health.zm	e49b526220bd44c99874fb5d4dd986dc	2026-09-16 08:06:25+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 08:06:26.36084+02	chanda.mwape@adch.health.zm
1354	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:09:39+02	Session	\N	\N	Start	null	{"exp": 1789540779, "jti": "ef43dff778a045faa6eee163e8f7cebd", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 08:09:39.605767+02	nkoleevans@gmail.com
1355	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:09:53+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 08:09:54.184459+02	nkoleevans@gmail.com
1356	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:09:55+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 08:09:55.607599+02	nkoleevans@gmail.com
1357	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:09:58+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 08:09:58.880907+02	nkoleevans@gmail.com
1358	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:10:00+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 08:10:00.873456+02	nkoleevans@gmail.com
1359	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:10:04+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 08:10:04.73828+02	nkoleevans@gmail.com
1360	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:10:10+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 08:10:11.169748+02	nkoleevans@gmail.com
1361	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:10:40+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 08:10:41.406103+02	nkoleevans@gmail.com
1362	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:10:58+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 08:10:59.445407+02	nkoleevans@gmail.com
1363	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:01+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 08:11:02.139846+02	nkoleevans@gmail.com
1364	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:03+02	Role List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:03.604389+02	nkoleevans@gmail.com
1365	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:03+02	Data Migration	\N	\N	View - Allowed	null	null	2026-09-16 08:11:04.090487+02	nkoleevans@gmail.com
1366	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:04+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 08:11:04.977382+02	nkoleevans@gmail.com
1367	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:09+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:09.611285+02	nkoleevans@gmail.com
1368	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:09+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:10.227162+02	nkoleevans@gmail.com
1369	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:24+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:25.320483+02	nkoleevans@gmail.com
1370	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:28+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:28.986431+02	nkoleevans@gmail.com
1371	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:31+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:31.941657+02	nkoleevans@gmail.com
1372	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:42+02	Round Evaluation	\N	\N	View - Allowed	null	null	2026-09-16 08:11:43.449749+02	nkoleevans@gmail.com
1373	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:11:56+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 08:11:57.128254+02	nkoleevans@gmail.com
1374	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:12:07+02	Service List	\N	\N	View - Allowed	null	null	2026-09-16 08:12:08.265133+02	nkoleevans@gmail.com
1375	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:12:08+02	Method List	\N	\N	View - Allowed	null	null	2026-09-16 08:12:09.007054+02	nkoleevans@gmail.com
1376	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:12:14+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 08:12:14.564767+02	nkoleevans@gmail.com
1377	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:12:18+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 08:12:19.171063+02	nkoleevans@gmail.com
1378	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:17:11+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 08:17:12.427898+02	nkoleevans@gmail.com
1379	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:18:08+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 08:18:09.682752+02	nkoleevans@gmail.com
1380	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:18:33+02	Review Application	\N	\N	View - Allowed	null	null	2026-09-16 08:18:34.41765+02	nkoleevans@gmail.com
1381	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:18:39+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 08:18:39.741825+02	nkoleevans@gmail.com
1382	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:18:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 08:18:44.010146+02	nkoleevans@gmail.com
1383	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:18:49+02	Round Evaluation	\N	\N	View - Allowed	null	null	2026-09-16 08:18:50.032946+02	nkoleevans@gmail.com
1384	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:03+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 08:19:04.131744+02	nkoleevans@gmail.com
1385	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:10+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 08:19:11.448111+02	nkoleevans@gmail.com
1386	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:37+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 08:19:38.532693+02	nkoleevans@gmail.com
1387	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:38+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-09-16 08:19:38.907377+02	nkoleevans@gmail.com
1388	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:39+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-16 08:19:39.526485+02	nkoleevans@gmail.com
1389	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:39+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 08:19:39.990676+02	nkoleevans@gmail.com
1390	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:19:41+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-09-16 08:19:41.547079+02	nkoleevans@gmail.com
1391	163	nkoleevans@gmail.com	ef43dff778a045faa6eee163e8f7cebd	2026-09-16 08:21:04+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 08:21:04.892371+02	nkoleevans@gmail.com
1392	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:13+02	Session	\N	\N	Start	null	{"exp": 1789541533, "jti": "4c0dc1bcce81465da2b2bd1cb3258608", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260977804242", "userid": 152}	2026-09-16 08:22:14.372618+02	chanda.mwape@adch.health.zm
1393	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:15+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:16.298907+02	chanda.mwape@adch.health.zm
1394	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:17+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:18.155781+02	chanda.mwape@adch.health.zm
1395	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:18+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:18.933982+02	chanda.mwape@adch.health.zm
1396	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:19+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:20.294246+02	chanda.mwape@adch.health.zm
1397	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:20+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 08:22:21.194738+02	chanda.mwape@adch.health.zm
1398	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:22+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:22.811918+02	chanda.mwape@adch.health.zm
1399	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:28+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:29.115503+02	chanda.mwape@adch.health.zm
1400	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:29+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:30.061328+02	chanda.mwape@adch.health.zm
1401	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:30+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:31.090928+02	chanda.mwape@adch.health.zm
1402	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:31+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 08:22:31.704153+02	chanda.mwape@adch.health.zm
1403	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:22:34+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:22:34.862284+02	chanda.mwape@adch.health.zm
1404	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:06+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:07.281766+02	chanda.mwape@adch.health.zm
1405	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:07+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:07.803227+02	chanda.mwape@adch.health.zm
1406	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:07+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:08.346348+02	chanda.mwape@adch.health.zm
1407	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:08+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:09.047406+02	chanda.mwape@adch.health.zm
1408	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:09+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:10.333253+02	chanda.mwape@adch.health.zm
1409	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:10+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:10.818275+02	chanda.mwape@adch.health.zm
1410	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:23:10+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:23:11.275833+02	chanda.mwape@adch.health.zm
1411	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:17+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:24:18.409171+02	chanda.mwape@adch.health.zm
1412	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:45+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:24:46.105494+02	chanda.mwape@adch.health.zm
1413	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:46+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 08:24:47.136938+02	chanda.mwape@adch.health.zm
1414	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:47+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:24:48.062661+02	chanda.mwape@adch.health.zm
1415	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:48+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 08:24:48.989747+02	chanda.mwape@adch.health.zm
1416	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:49+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 08:24:49.791959+02	chanda.mwape@adch.health.zm
1417	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:24:50+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 08:24:50.658212+02	chanda.mwape@adch.health.zm
1418	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:28:46+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 08:28:47.776597+02	chanda.mwape@adch.health.zm
1419	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:28:48+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 08:28:48.971069+02	chanda.mwape@adch.health.zm
1420	152	chanda.mwape@adch.health.zm	4c0dc1bcce81465da2b2bd1cb3258608	2026-09-16 08:28:49+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 08:28:49.64745+02	chanda.mwape@adch.health.zm
1421	163	nkoleevans@gmail.com	871adc6199a44b5c8fd85c0281593086	2026-09-16 10:10:48+02	Session	\N	\N	Start	null	{"exp": 1789548048, "jti": "871adc6199a44b5c8fd85c0281593086", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 10:10:48.727892+02	nkoleevans@gmail.com
1422	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:22:14+02	Session	\N	\N	Start	null	{"exp": 1789548740, "jti": "4ff5e89879594efaa0cc1441ade9ce9f", "lab": null, "sub": "wanangwa@gmail.com", "name": "Kelvin Doh", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-16 10:22:21.077145+02	wanangwa@gmail.com
1423	0	nkoleevans@gamil.com	public	2026-09-16 10:22:46+02	Authentication	\N	\N	Unauthorised	null	null	2026-09-16 10:22:46.594452+02	nkoleevans@gamil.com
1427	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:23:13+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:23:19.913609+02	wanangwa@gmail.com
1424	163	nkoleevans@gmail.com	21e9927539224714b228003ca5b18783	2026-09-16 10:22:51+02	Session	\N	\N	Start	null	{"exp": 1789548771, "jti": "21e9927539224714b228003ca5b18783", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 10:22:51.812463+02	nkoleevans@gmail.com
1425	163	nkoleevans@gmail.com	21e9927539224714b228003ca5b18783	2026-09-16 10:22:54+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:22:55.326113+02	nkoleevans@gmail.com
1426	163	nkoleevans@gmail.com	21e9927539224714b228003ca5b18783	2026-09-16 10:22:56+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:22:56.806112+02	nkoleevans@gmail.com
1429	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:24:07+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-16 10:24:06.388998+02	beniah@gmail.com
1430	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:24:05+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:24:11.30515+02	wanangwa@gmail.com
1432	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:24:25+02	Service List	\N	\N	View - Allowed	null	null	2026-09-16 10:24:24.602819+02	beniah@gmail.com
1434	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:26:21+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:26:20.182888+02	beniah@gmail.com
1436	163	nkoleevans@gmail.com	871adc6199a44b5c8fd85c0281593086	2026-09-16 10:31:19+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:31:20.026358+02	nkoleevans@gmail.com
1438	163	nkoleevans@gmail.com	871adc6199a44b5c8fd85c0281593086	2026-09-16 10:31:28+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:31:28.575346+02	nkoleevans@gmail.com
1439	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:34:11+02	Session	\N	\N	Start	null	{"exp": 1789549451, "jti": "214d26c6387941ab9e39dff0912c22bc", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 10:34:12.444673+02	nkoleevans@gmail.com
1428	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:23:29+02	Session	\N	\N	Start	null	{"exp": 1789548807, "jti": "4e340263486243c4985de479e9eb5c1d", "lab": null, "sub": "beniah@gmail.com", "name": "Kelvin Doh", "role": 1, "mobile": "+260978989259", "userid": 175}	2026-09-16 10:23:28.680832+02	beniah@gmail.com
1431	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:24:23+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:24:21.962054+02	beniah@gmail.com
1433	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:24:33+02	Province List	\N	\N	View - Allowed	null	null	2026-09-16 10:24:54.240335+02	wanangwa@gmail.com
1435	163	nkoleevans@gmail.com	871adc6199a44b5c8fd85c0281593086	2026-09-16 10:30:04+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:30:05.195592+02	nkoleevans@gmail.com
1437	163	nkoleevans@gmail.com	871adc6199a44b5c8fd85c0281593086	2026-09-16 10:31:26+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:31:26.643077+02	nkoleevans@gmail.com
1440	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:34:21+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:34:23.93011+02	nkoleevans@gmail.com
1441	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:34:51+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-16 10:34:52.456442+02	nkoleevans@gmail.com
1442	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:34:57+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:34:58.244707+02	nkoleevans@gmail.com
1443	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:36:00+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:36:01.067794+02	nkoleevans@gmail.com
1444	147	jane@gmail.com	12e9d4c3e52a40d7923598d925f98755	2026-09-16 10:37:46+02	Session	\N	\N	Start	null	{"exp": 1789549668, "jti": "12e9d4c3e52a40d7923598d925f98755", "lab": 2, "sub": "jane@gmail.com", "name": "Jane Banda", "role": 9, "mobile": "+260972989302", "userid": 147}	2026-09-16 10:37:51.559703+02	jane@gmail.com
1445	151	peter.zulu@kitwe.health.zm	39dae630504344298bf80cd016268337	2026-09-16 10:37:47+02	Session	\N	\N	Start	null	{"exp": 1789549668, "jti": "39dae630504344298bf80cd016268337", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Peter Zulu", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 10:37:51.573067+02	peter.zulu@kitwe.health.zm
1446	146	musachoolwe@gmail.com	06156374144d435889edf06e37d7f792	2026-09-16 10:40:11+02	Session	\N	\N	Start	null	{"exp": 1789549810, "jti": "06156374144d435889edf06e37d7f792", "lab": 1, "sub": "musachoolwe@gmail.com", "name": "Musa Choolwe", "role": 9, "mobile": "+260970149211", "userid": 146}	2026-09-16 10:40:12.230632+02	musachoolwe@gmail.com
1447	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:40:55+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 10:40:56.268585+02	nkoleevans@gmail.com
1448	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:41:11+02	Review Application	\N	\N	View - Allowed	null	null	2026-09-16 10:41:11.685454+02	nkoleevans@gmail.com
1449	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:41:15+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 10:41:15.743033+02	nkoleevans@gmail.com
1450	150	grace.mulenga@ndola.health.zm	65e719e46cc64cd59ebae353a198909d	2026-09-16 10:41:16+02	Session	\N	\N	Start	null	{"exp": 1789549875, "jti": "65e719e46cc64cd59ebae353a198909d", "lab": 5, "sub": "grace.mulenga@ndola.health.zm", "name": "Grace Mulenga", "role": 9, "mobile": "+260970756914", "userid": 150}	2026-09-16 10:41:20.014278+02	grace.mulenga@ndola.health.zm
1451	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:41:36+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 10:41:36.672413+02	nkoleevans@gmail.com
1452	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:42:00+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 10:42:01.011635+02	nkoleevans@gmail.com
1453	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:42:03+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:42:04.186536+02	nkoleevans@gmail.com
1454	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:43:44+02	Province List	\N	\N	View - Allowed	null	null	2026-09-16 10:43:53.623436+02	wanangwa@gmail.com
1455	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:43:58+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:44:06.410933+02	wanangwa@gmail.com
1456	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:44:03+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:44:11.117698+02	wanangwa@gmail.com
1457	0	alanphiri@gmail.com	public	2026-09-16 10:44:29+02	Authentication	\N	\N	Unauthorised	null	null	2026-09-16 10:44:29.516988+02	alanphiri@gmail.com
1458	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:44:23+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:44:29.720863+02	wanangwa@gmail.com
1459	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 10:44:49+02	Session	\N	\N	Start	null	{"exp": 1789550088, "jti": "515e07e01a9a4a218f30cc6896a8cb26", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260974628136", "userid": 149}	2026-09-16 10:44:49.585195+02	alanphiri@gmail.com
1460	148	markdoe@gmail.com	c26a4de36e994822b22e2d0e470eb2b8	2026-09-16 10:44:40+02	Session	\N	\N	Start	null	{"exp": 1789550092, "jti": "c26a4de36e994822b22e2d0e470eb2b8", "lab": 3, "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "+260972441868", "userid": 148}	2026-09-16 10:44:53.169546+02	markdoe@gmail.com
1461	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 10:45:05+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 10:45:05.816856+02	alanphiri@gmail.com
1462	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:45:04+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:45:10.989004+02	wanangwa@gmail.com
1463	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 10:45:20+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 10:45:22.095565+02	alanphiri@gmail.com
1464	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 10:45:23+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 10:45:24.55859+02	alanphiri@gmail.com
1465	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:45:40+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:45:49.945215+02	wanangwa@gmail.com
1466	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:46:36+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:46:49.666559+02	wanangwa@gmail.com
1467	148	markdoe@gmail.com	09ae234583e747529dcef4c9ce2a6ecb	2026-09-16 10:46:37+02	Session	\N	\N	Start	null	{"exp": 1789550209, "jti": "09ae234583e747529dcef4c9ce2a6ecb", "lab": 3, "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "+260972441868", "userid": 148}	2026-09-16 10:46:54.292777+02	markdoe@gmail.com
1473	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:47:22+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:47:29.764956+02	wanangwa@gmail.com
1486	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:52:49+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:52:55.920822+02	wanangwa@gmail.com
1468	148	markdoe@gmail.com	a340c8eeaffa4681b909b6e0e31e89b1	2026-09-16 10:46:55+02	Session	\N	\N	Start	null	{"exp": 1789550226, "jti": "a340c8eeaffa4681b909b6e0e31e89b1", "lab": 3, "sub": "markdoe@gmail.com", "name": "Mark Doe", "role": 9, "mobile": "+260972441868", "userid": 148}	2026-09-16 10:47:09.827995+02	markdoe@gmail.com
1469	151	peter.zulu@kitwe.health.zm	9d13e06ae4034eefb3abe112c5bcc809	2026-09-16 10:47:08+02	Session	\N	\N	Start	null	{"exp": 1789550230, "jti": "9d13e06ae4034eefb3abe112c5bcc809", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 10:47:10.8575+02	peter.zulu@kitwe.health.zm
1475	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:47:57+02	View User	\N	\N	View - Allowed	null	null	2026-09-16 10:48:11.261245+02	wanangwa@gmail.com
1476	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:48:11+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:48:21.898129+02	wanangwa@gmail.com
1481	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:51:59+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:52:05.74078+02	wanangwa@gmail.com
1485	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:52:38+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:52:46.13964+02	wanangwa@gmail.com
1488	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:53:32+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:53:44.502747+02	wanangwa@gmail.com
1494	150	grace.mulenga@ndola.health.zm	4b74a359b6cb480f8e56c150845d7979	2026-09-16 10:55:47+02	Session	\N	\N	Start	null	{"exp": 1789550746, "jti": "4b74a359b6cb480f8e56c150845d7979", "lab": 5, "sub": "grace.mulenga@ndola.health.zm", "name": "Ephraim --", "role": 9, "mobile": "+260970756914", "userid": 150}	2026-09-16 10:55:55.210381+02	grace.mulenga@ndola.health.zm
1497	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 10:56:38+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 10:56:38.847154+02	nkoleevans@gmail.com
1507	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:01+02	Service List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:01.914132+02	nkoleevans@gmail.com
1514	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:04:24+02	Service List	\N	\N	View - Allowed	null	null	2026-09-16 11:04:25.201906+02	nkoleevans@gmail.com
1516	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:05:05+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 11:05:06.378231+02	nkoleevans@gmail.com
1520	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 11:06:51+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 11:06:52.99915+02	alanphiri@gmail.com
1524	146	musachoolwe@gmail.com	e7634e484d384d4e8e2b8f1049f5c19f	2026-09-16 11:07:35+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:07:36.052299+02	musachoolwe@gmail.com
1528	148	markdoe@gmail.com	c251ac9f89cb4bfd92e469c0f012b168	2026-09-16 11:23:05+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 11:23:18.237218+02	markdoe@gmail.com
1535	174	kelvin@gmail.com	ae026e2001784993b9ac092ce45fee7c	2026-09-16 11:24:45+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 11:24:45.74885+02	kelvin@gmail.com
1538	0	peter.zulu@kitwe.health.zm	public	2026-09-16 11:25:13+02	Authentication	\N	\N	Unauthorised	null	null	2026-09-16 11:25:13.768198+02	peter.zulu@kitwe.health.zm
1545	174	kelvin@gmail.com	9b084de9d4d54e4e8f1e667ffb24174a	2026-09-16 11:26:12+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 11:26:13.239913+02	kelvin@gmail.com
1553	1	wanangwa@gmail.com	4df98bf5a58947b88bc68c4733670b53	2026-09-16 11:27:19+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 11:27:25.828792+02	wanangwa@gmail.com
1557	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 11:28:15+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:28:20.758788+02	alanphiri@gmail.com
1558	1	wanangwa@gmail.com	4df98bf5a58947b88bc68c4733670b53	2026-09-16 11:33:31+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 11:33:40.134387+02	wanangwa@gmail.com
1561	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:34:38+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:34:38.957237+02	kelvin@gmail.com
1566	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:36:23+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:36:24.340487+02	kelvin@gmail.com
1570	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 11:37:19+02	Session	\N	\N	Start	null	{"exp": 1789553237, "jti": "32d1a88632f34de2bdbb245bb7051a02", "lab": 51, "sub": "lkampamba@gmail.com", "name": "Lombe Kampamba", "role": 9, "mobile": "0968656556", "userid": 176}	2026-09-16 11:37:31.553165+02	lkampamba@gmail.com
1575	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:38:20+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:38:21.534516+02	kelvin@gmail.com
1603	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:22+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:48:22.991204+02	kelvin@gmail.com
1606	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:31+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:48:32.205746+02	kelvin@gmail.com
1610	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:44+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:48:44.689378+02	kelvin@gmail.com
1619	151	peter.zulu@kitwe.health.zm	5a80ac13049d4c1ea72a17504602fb92	2026-09-16 11:53:05+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:53:07.081299+02	peter.zulu@kitwe.health.zm
1621	163	nkoleevans@gmail.com	7def4625d3d940e6a5682d779b7499a6	2026-09-16 11:54:10+02	Session	\N	\N	Start	null	{"exp": 1789554250, "jti": "7def4625d3d940e6a5682d779b7499a6", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 11:54:11.510648+02	nkoleevans@gmail.com
1623	163	nkoleevans@gmail.com	7def4625d3d940e6a5682d779b7499a6	2026-09-16 11:54:16+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 11:54:16.735109+02	nkoleevans@gmail.com
1624	163	nkoleevans@gmail.com	7def4625d3d940e6a5682d779b7499a6	2026-09-16 11:54:38+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:54:41.918471+02	nkoleevans@gmail.com
1627	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 11:57:12+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 11:57:13.723781+02	peter.zulu@kitwe.health.zm
1630	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 11:57:50+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 11:57:51.52333+02	peter.zulu@kitwe.health.zm
1631	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:04:44+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:04:43.657558+02	lkampamba@gmail.com
1470	146	musachoolwe@gmail.com	39d738e1803b4ca4b5d681edd8a3b04a	2026-09-16 10:47:15+02	Session	\N	\N	Start	null	{"exp": 1789550233, "jti": "39d738e1803b4ca4b5d681edd8a3b04a", "lab": 1, "sub": "musachoolwe@gmail.com", "name": "Musa Choolwe", "role": 9, "mobile": "+260970149211", "userid": 146}	2026-09-16 10:47:16.132258+02	musachoolwe@gmail.com
1471	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:47:11+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:47:17.238511+02	wanangwa@gmail.com
1472	150	grace.mulenga@ndola.health.zm	1f544eb7a91f48b89df8f265f6359d46	2026-09-16 10:47:27+02	Session	\N	\N	Start	null	{"exp": 1789550246, "jti": "1f544eb7a91f48b89df8f265f6359d46", "lab": 5, "sub": "grace.mulenga@ndola.health.zm", "name": "Grace Mulenga", "role": 9, "mobile": "+260970756914", "userid": 150}	2026-09-16 10:47:27.80095+02	grace.mulenga@ndola.health.zm
1474	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:47:46+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:47:52.34072+02	wanangwa@gmail.com
1478	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:51:41+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:51:47.733903+02	wanangwa@gmail.com
1480	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:51:58+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:51:58.626655+02	nkoleevans@gmail.com
1483	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:52:16+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:52:24.336213+02	wanangwa@gmail.com
1484	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:52:27+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:52:31.938193+02	beniah@gmail.com
1487	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:53:10+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:53:21.989549+02	wanangwa@gmail.com
1490	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:54:29+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:54:35.880258+02	wanangwa@gmail.com
1491	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:54:48+02	User	\N	\N	View - Allowed	null	null	2026-09-16 10:54:59.082793+02	wanangwa@gmail.com
1498	1	wanangwa@gmail.com	86aef6389e77468c90bede5e37e9f7f4	2026-09-16 10:56:47+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 10:56:53.8844+02	wanangwa@gmail.com
1500	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 10:57:25+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 10:57:25.862136+02	nkoleevans@gmail.com
1502	149	alanphiri@gmail.com	515e07e01a9a4a218f30cc6896a8cb26	2026-09-16 11:02:37+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 11:02:39.764407+02	alanphiri@gmail.com
1503	148	markdoe@gmail.com	c251ac9f89cb4bfd92e469c0f012b168	2026-09-16 11:02:31+02	Session	\N	\N	Start	null	{"exp": 1789551163, "jti": "c251ac9f89cb4bfd92e469c0f012b168", "lab": 3, "sub": "markdoe@gmail.com", "name": "Steven --", "role": 9, "mobile": "+260972441868", "userid": 148}	2026-09-16 11:02:44.376788+02	markdoe@gmail.com
1505	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:02:59+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:00.503355+02	nkoleevans@gmail.com
1508	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:01+02	Method List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:02.444552+02	nkoleevans@gmail.com
1511	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:15+02	Provider	\N	\N	View - Allowed	null	null	2026-09-16 11:03:16.131646+02	nkoleevans@gmail.com
1517	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:05:14+02	Service List	\N	\N	View - Allowed	null	null	2026-09-16 11:05:14.882812+02	nkoleevans@gmail.com
1521	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:07:23+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:07:25.7927+02	nkoleevans@gmail.com
1527	148	markdoe@gmail.com	c251ac9f89cb4bfd92e469c0f012b168	2026-09-16 11:22:53+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:23:08.920693+02	markdoe@gmail.com
1529	148	markdoe@gmail.com	c251ac9f89cb4bfd92e469c0f012b168	2026-09-16 11:23:10+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 11:23:23.333926+02	markdoe@gmail.com
1531	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:23:59+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 11:23:59.86429+02	nkoleevans@gmail.com
1534	174	kelvin@gmail.com	ae026e2001784993b9ac092ce45fee7c	2026-09-16 11:24:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:24:44.47002+02	kelvin@gmail.com
1537	174	kelvin@gmail.com	ae026e2001784993b9ac092ce45fee7c	2026-09-16 11:24:54+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:24:55.372363+02	kelvin@gmail.com
1544	174	kelvin@gmail.com	9b084de9d4d54e4e8f1e667ffb24174a	2026-09-16 11:26:06+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:26:08.225743+02	kelvin@gmail.com
1546	174	kelvin@gmail.com	9b084de9d4d54e4e8f1e667ffb24174a	2026-09-16 11:26:34+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:26:34.725779+02	kelvin@gmail.com
1547	151	peter.zulu@kitwe.health.zm	fde011325b3846888ba02be01239b36d	2026-09-16 11:26:50+02	Session	\N	\N	Start	null	{"exp": 1789552610, "jti": "fde011325b3846888ba02be01239b36d", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 11:26:50.972832+02	peter.zulu@kitwe.health.zm
1548	151	peter.zulu@kitwe.health.zm	fde011325b3846888ba02be01239b36d	2026-09-16 11:26:54+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:26:55.451669+02	peter.zulu@kitwe.health.zm
1549	151	peter.zulu@kitwe.health.zm	9d13e06ae4034eefb3abe112c5bcc809	2026-09-16 11:27:07+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:27:09.582747+02	peter.zulu@kitwe.health.zm
1559	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:34:04+02	Session	\N	\N	Start	null	{"exp": 1789553044, "jti": "5dc7b01af9c541e4849cdc9800abd03e", "lab": null, "sub": "kelvin@gmail.com", "name": "Kelvin Doh", "role": 1, "mobile": "+260978989259", "userid": 174}	2026-09-16 11:34:05.190047+02	kelvin@gmail.com
1562	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:35:18+02	Session	\N	\N	Start	null	{"exp": 1789553130, "jti": "7e79b50e2ef7445e8918a0aebc0fc5e1", "lab": 3, "sub": "markdoe@gmail.com", "name": "Steven --", "role": 9, "mobile": "+260972441868", "userid": 148}	2026-09-16 11:35:31.142944+02	markdoe@gmail.com
1565	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:36:20+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:36:20.763749+02	kelvin@gmail.com
1572	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 11:37:30+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:37:40.355853+02	peter.zulu@kitwe.health.zm
1580	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:05+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:45:05.924227+02	kelvin@gmail.com
1592	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:09+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:46:10.144248+02	kelvin@gmail.com
1477	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:50:19+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:50:20.346933+02	nkoleevans@gmail.com
1479	163	nkoleevans@gmail.com	214d26c6387941ab9e39dff0912c22bc	2026-09-16 10:51:53+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 10:51:54.348002+02	nkoleevans@gmail.com
1482	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:52:12+02	View User	\N	\N	View - Allowed	null	null	2026-09-16 10:52:18.93149+02	wanangwa@gmail.com
1493	1	wanangwa@gmail.com	4ff5e89879594efaa0cc1441ade9ce9f	2026-09-16 10:55:14+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:55:21.202749+02	wanangwa@gmail.com
1496	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 10:56:35+02	Session	\N	\N	Start	null	{"exp": 1789550795, "jti": "d56904704218443785966a164b4418d1", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 10:56:36.093245+02	nkoleevans@gmail.com
1499	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 10:56:55+02	Review Laboratory	\N	\N	View - Allowed	null	null	2026-09-16 10:56:55.749492+02	nkoleevans@gmail.com
1504	176	lkampamba@gmail.com	d5aa04b844e549eebc17bc6083f6b9d7	2026-09-16 11:02:59+02	Session	\N	\N	Start	null	{"exp": 1789551177, "jti": "d5aa04b844e549eebc17bc6083f6b9d7", "lab": 51, "sub": "lkampamba@gmail.com", "name": "Lombe Kampamba", "role": 9, "mobile": "0968656556", "userid": 176}	2026-09-16 11:02:59.582473+02	lkampamba@gmail.com
1509	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:02+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:03.346078+02	nkoleevans@gmail.com
1512	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:46+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:46.9617+02	nkoleevans@gmail.com
1518	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:05:31+02	Method List	\N	\N	View - Allowed	null	null	2026-09-16 11:05:31.592643+02	nkoleevans@gmail.com
1522	1	wanangwa@gmail.com	86aef6389e77468c90bede5e37e9f7f4	2026-09-16 11:07:19+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:07:25.991667+02	wanangwa@gmail.com
1536	174	kelvin@gmail.com	ae026e2001784993b9ac092ce45fee7c	2026-09-16 11:24:49+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:24:51.848722+02	kelvin@gmail.com
1550	148	markdoe@gmail.com	c251ac9f89cb4bfd92e469c0f012b168	2026-09-16 11:26:59+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:27:11.881635+02	markdoe@gmail.com
1554	150	grace.mulenga@ndola.health.zm	b5be621590ea43ada6ce06b3808ad8be	2026-09-16 11:27:45+02	Session	\N	\N	Start	null	{"exp": 1789552665, "jti": "b5be621590ea43ada6ce06b3808ad8be", "lab": 5, "sub": "grace.mulenga@ndola.health.zm", "name": "Ephraim --", "role": 9, "mobile": "+260970756914", "userid": 150}	2026-09-16 11:27:46.040246+02	grace.mulenga@ndola.health.zm
1560	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:34:07+02	Application List	\N	\N	View - Allowed	null	null	2026-09-16 11:34:10.262232+02	kelvin@gmail.com
1564	150	grace.mulenga@ndola.health.zm	b5be621590ea43ada6ce06b3808ad8be	2026-09-16 11:36:08+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:36:12.650108+02	grace.mulenga@ndola.health.zm
1569	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:37:00+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 11:37:16.728501+02	markdoe@gmail.com
1571	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:37:07+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 11:37:31.997092+02	markdoe@gmail.com
1577	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:39:05+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:39:19.232149+02	markdoe@gmail.com
1582	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:21+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:45:22.367643+02	kelvin@gmail.com
1585	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:37+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:45:40.70132+02	kelvin@gmail.com
1588	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:58+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:45:59.112216+02	kelvin@gmail.com
1591	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:04+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:46:06.582611+02	kelvin@gmail.com
1594	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:20+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:46:20.874502+02	kelvin@gmail.com
1597	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:34+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:46:34.808188+02	kelvin@gmail.com
1600	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:12+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:48:12.817347+02	kelvin@gmail.com
1605	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:29+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:48:29.815409+02	kelvin@gmail.com
1608	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:36+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:48:36.984982+02	kelvin@gmail.com
1632	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:05:03+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:05:03.003706+02	lkampamba@gmail.com
1489	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 10:53:44+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-09-16 10:54:02.156412+02	beniah@gmail.com
1492	146	musachoolwe@gmail.com	e7634e484d384d4e8e2b8f1049f5c19f	2026-09-16 10:54:55+02	Session	\N	\N	Start	null	{"exp": 1789550694, "jti": "e7634e484d384d4e8e2b8f1049f5c19f", "lab": 1, "sub": "musachoolwe@gmail.com", "name": "Victor --", "role": 9, "mobile": "+260970149211", "userid": 146}	2026-09-16 10:54:59.551419+02	musachoolwe@gmail.com
1495	1	wanangwa@gmail.com	86aef6389e77468c90bede5e37e9f7f4	2026-09-16 10:55:44+02	Session	\N	\N	Start	null	{"exp": 1789550749, "jti": "86aef6389e77468c90bede5e37e9f7f4", "lab": null, "sub": "wanangwa@gmail.com", "name": "Wanangwa Doh", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-16 10:55:56.903245+02	wanangwa@gmail.com
1501	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 10:57:28+02	Users	\N	\N	View - Allowed	null	null	2026-09-16 10:57:29.461642+02	nkoleevans@gmail.com
1506	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:00+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:01.291134+02	nkoleevans@gmail.com
1510	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:13+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:15.370703+02	nkoleevans@gmail.com
1513	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:03:54+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-16 11:03:56.228502+02	nkoleevans@gmail.com
1515	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:04:51+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-16 11:04:52.309702+02	nkoleevans@gmail.com
1519	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:06:31+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-16 11:06:32.06582+02	nkoleevans@gmail.com
1523	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:07:25+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 11:07:26.443568+02	nkoleevans@gmail.com
1525	175	beniah@gmail.com	4e340263486243c4985de479e9eb5c1d	2026-09-16 11:09:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:09:58.12443+02	beniah@gmail.com
1526	146	musachoolwe@gmail.com	e7634e484d384d4e8e2b8f1049f5c19f	2026-09-16 11:21:10+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:21:10.600684+02	musachoolwe@gmail.com
1530	163	nkoleevans@gmail.com	d56904704218443785966a164b4418d1	2026-09-16 11:23:47+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:23:48.498281+02	nkoleevans@gmail.com
1532	1	wanangwa@gmail.com	86aef6389e77468c90bede5e37e9f7f4	2026-09-16 11:23:59+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:24:05.780617+02	wanangwa@gmail.com
1533	174	kelvin@gmail.com	ae026e2001784993b9ac092ce45fee7c	2026-09-16 11:24:20+02	Session	\N	\N	Start	null	{"exp": 1789552460, "jti": "ae026e2001784993b9ac092ce45fee7c", "lab": null, "sub": "kelvin@gmail.com", "name": "Kelvin Doh", "role": 1, "mobile": "+260978989259", "userid": 174}	2026-09-16 11:24:21.24492+02	kelvin@gmail.com
1539	0	peter.zulu@kitwe.health.zm	public	2026-09-16 11:25:22+02	Authentication	\N	\N	Unauthorised	null	null	2026-09-16 11:25:22.802607+02	peter.zulu@kitwe.health.zm
1540	151	peter.zulu@kitwe.health.zm	afd3a70e335c44fe8e8bdedee5e91a70	2026-09-16 11:25:30+02	Session	\N	\N	Start	null	{"exp": 1789552530, "jti": "afd3a70e335c44fe8e8bdedee5e91a70", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 11:25:31.26196+02	peter.zulu@kitwe.health.zm
1541	151	peter.zulu@kitwe.health.zm	afd3a70e335c44fe8e8bdedee5e91a70	2026-09-16 11:25:34+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:25:36.557394+02	peter.zulu@kitwe.health.zm
1542	151	peter.zulu@kitwe.health.zm	afd3a70e335c44fe8e8bdedee5e91a70	2026-09-16 11:25:52+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:25:57.492896+02	peter.zulu@kitwe.health.zm
1543	174	kelvin@gmail.com	9b084de9d4d54e4e8f1e667ffb24174a	2026-09-16 11:26:03+02	Session	\N	\N	Start	null	{"exp": 1789552563, "jti": "9b084de9d4d54e4e8f1e667ffb24174a", "lab": null, "sub": "kelvin@gmail.com", "name": "Kelvin Doh", "role": 1, "mobile": "+260978989259", "userid": 174}	2026-09-16 11:26:03.904167+02	kelvin@gmail.com
1551	1	wanangwa@gmail.com	4df98bf5a58947b88bc68c4733670b53	2026-09-16 11:27:07+02	Session	\N	\N	Start	null	{"exp": 1789552632, "jti": "4df98bf5a58947b88bc68c4733670b53", "lab": null, "sub": "wanangwa@gmail.com", "name": "Wanangwa Doh", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-16 11:27:14.725023+02	wanangwa@gmail.com
1552	176	lkampamba@gmail.com	d5aa04b844e549eebc17bc6083f6b9d7	2026-09-16 11:27:14+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:27:15.29067+02	lkampamba@gmail.com
1555	151	peter.zulu@kitwe.health.zm	fde011325b3846888ba02be01239b36d	2026-09-16 11:27:58+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:27:59.27352+02	peter.zulu@kitwe.health.zm
1556	150	grace.mulenga@ndola.health.zm	b5be621590ea43ada6ce06b3808ad8be	2026-09-16 11:28:06+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:28:12.113288+02	grace.mulenga@ndola.health.zm
1563	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:35:25+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:35:37.929709+02	markdoe@gmail.com
1567	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 11:36:46+02	Session	\N	\N	Start	null	{"exp": 1789553208, "jti": "c7348ee4ad7c4bdd9352779030468df9", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 11:36:51.654082+02	peter.zulu@kitwe.health.zm
1568	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:36:57+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 11:37:10.003963+02	markdoe@gmail.com
1573	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:37:23+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:37:45.1388+02	markdoe@gmail.com
1574	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 11:37:26+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:37:48.703263+02	lkampamba@gmail.com
1576	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:38:38+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 11:38:53.238034+02	markdoe@gmail.com
1578	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 11:43:28+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:43:30.857871+02	lkampamba@gmail.com
1579	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:44:50+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:44:51.012894+02	kelvin@gmail.com
1581	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:07+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:45:08.4517+02	kelvin@gmail.com
1583	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:25+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:45:25.631967+02	kelvin@gmail.com
1584	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:34+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:45:34.794518+02	kelvin@gmail.com
1586	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:45+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:45:46.023532+02	kelvin@gmail.com
1589	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:01+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:46:02.034371+02	kelvin@gmail.com
1615	163	nkoleevans@gmail.com	cd7b4c694b4447b9a45deeb2724ccf4f	2026-09-16 11:51:54+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:51:54.616746+02	nkoleevans@gmail.com
1618	151	peter.zulu@kitwe.health.zm	5a80ac13049d4c1ea72a17504602fb92	2026-09-16 11:53:02+02	Session	\N	\N	Start	null	{"exp": 1789554182, "jti": "5a80ac13049d4c1ea72a17504602fb92", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 11:53:03.518794+02	peter.zulu@kitwe.health.zm
1622	163	nkoleevans@gmail.com	7def4625d3d940e6a5682d779b7499a6	2026-09-16 11:54:13+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 11:54:15.918181+02	nkoleevans@gmail.com
1626	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 11:54:53+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:54:54.32856+02	peter.zulu@kitwe.health.zm
1633	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 12:05:03+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:05:14.645012+02	peter.zulu@kitwe.health.zm
1587	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:45:48+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:45:51.55359+02	kelvin@gmail.com
1590	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:45:49+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:46:02.369794+02	markdoe@gmail.com
1593	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:15+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:46:16.253967+02	kelvin@gmail.com
1596	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:29+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:46:32.412532+02	kelvin@gmail.com
1599	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:47:05+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:47:05.877736+02	kelvin@gmail.com
1602	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:19+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:48:20.200513+02	kelvin@gmail.com
1607	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:33+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:48:34.213603+02	kelvin@gmail.com
1612	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 11:50:01+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:50:04.833999+02	lkampamba@gmail.com
1613	150	grace.mulenga@ndola.health.zm	b5be621590ea43ada6ce06b3808ad8be	2026-09-16 11:50:19+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:50:23.080039+02	grace.mulenga@ndola.health.zm
1614	163	nkoleevans@gmail.com	cd7b4c694b4447b9a45deeb2724ccf4f	2026-09-16 11:50:30+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:50:30.682057+02	nkoleevans@gmail.com
1616	163	nkoleevans@gmail.com	cd7b4c694b4447b9a45deeb2724ccf4f	2026-09-16 11:51:55+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 11:51:56.543111+02	nkoleevans@gmail.com
1620	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 11:53:15+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:53:29.318135+02	markdoe@gmail.com
1625	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 11:54:50+02	Session	\N	\N	Start	null	{"exp": 1789554290, "jti": "09ca02bb34ea469d923d0906b1602d92", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 11:54:51.111392+02	peter.zulu@kitwe.health.zm
1628	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 11:57:16+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 11:57:17.310883+02	peter.zulu@kitwe.health.zm
1634	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 12:05:15+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:05:18.300622+02	peter.zulu@kitwe.health.zm
1595	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:25+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:46:25.624324+02	kelvin@gmail.com
1598	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:46:38+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:46:45.18536+02	kelvin@gmail.com
1601	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:17+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:48:17.789587+02	kelvin@gmail.com
1604	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:24+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:48:25.257264+02	kelvin@gmail.com
1609	174	kelvin@gmail.com	5dc7b01af9c541e4849cdc9800abd03e	2026-09-16 11:48:40+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-16 11:48:41.300073+02	kelvin@gmail.com
1611	163	nkoleevans@gmail.com	cd7b4c694b4447b9a45deeb2724ccf4f	2026-09-16 11:49:23+02	Session	\N	\N	Start	null	{"exp": 1789553963, "jti": "cd7b4c694b4447b9a45deeb2724ccf4f", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 11:49:23.644827+02	nkoleevans@gmail.com
1617	163	nkoleevans@gmail.com	cd7b4c694b4447b9a45deeb2724ccf4f	2026-09-16 11:52:26+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-16 11:52:27.396608+02	nkoleevans@gmail.com
1629	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 11:57:24+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 11:57:25.782928+02	peter.zulu@kitwe.health.zm
1635	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 12:05:40+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:05:42.58345+02	peter.zulu@kitwe.health.zm
1636	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:06:00+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:05:58.972972+02	lkampamba@gmail.com
1637	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:06:22+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:06:22.886042+02	lkampamba@gmail.com
1638	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:06:37+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:06:50.223325+02	markdoe@gmail.com
1639	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:06:40+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 12:06:53.277273+02	markdoe@gmail.com
1640	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:06:44+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 12:06:57.044094+02	markdoe@gmail.com
1641	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:06:47+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 12:07:00.208703+02	markdoe@gmail.com
1642	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:06:50+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 12:07:02.843495+02	markdoe@gmail.com
1643	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:06:56+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:07:10.040725+02	markdoe@gmail.com
1644	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:07:03+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 12:07:18.743713+02	markdoe@gmail.com
1645	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:07:07+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:07:21.777223+02	markdoe@gmail.com
1646	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:07:29+02	Session	\N	\N	Start	null	{"exp": 1789555049, "jti": "4b39fb5c46084373bab6ad435f021d8c", "lab": 5, "sub": "grace.mulenga@ndola.health.zm", "name": "Ephraim --", "role": 9, "mobile": "+260970756914", "userid": 150}	2026-09-16 12:07:31.128009+02	grace.mulenga@ndola.health.zm
1647	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:07:20+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:07:35.952905+02	markdoe@gmail.com
1648	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:07:46+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:07:47.772864+02	grace.mulenga@ndola.health.zm
1649	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:08:03+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:08:03.632155+02	grace.mulenga@ndola.health.zm
1650	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:08:41+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:08:54.290037+02	markdoe@gmail.com
1651	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:08:48+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:09:01.452629+02	markdoe@gmail.com
1652	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:08:52+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:05.398912+02	markdoe@gmail.com
1653	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:08:57+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:09.932125+02	markdoe@gmail.com
1654	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:08:59+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:13.123451+02	markdoe@gmail.com
1655	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:03+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:16.178848+02	markdoe@gmail.com
1656	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:05+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 12:09:23.425354+02	markdoe@gmail.com
1657	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:18+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:09:33.280355+02	markdoe@gmail.com
1658	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:24+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:38.198114+02	markdoe@gmail.com
1659	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:39+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:53.82522+02	markdoe@gmail.com
1660	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:43+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-16 12:09:55.829049+02	markdoe@gmail.com
1661	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:51+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-16 12:10:04.669856+02	markdoe@gmail.com
1662	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 12:10:05+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:10:05.942833+02	peter.zulu@kitwe.health.zm
1663	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:09:56+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:10:10.474368+02	markdoe@gmail.com
1664	151	peter.zulu@kitwe.health.zm	09ca02bb34ea469d923d0906b1602d92	2026-09-16 12:10:12+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:10:13.025846+02	peter.zulu@kitwe.health.zm
1665	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:10:32+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:10:49.052864+02	markdoe@gmail.com
1668	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:11:49+02	Session	\N	\N	Start	null	{"exp": 1789555309, "jti": "4aa01c82fe034dba9598d26ef701a430", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 12:11:49.636146+02	nkoleevans@gmail.com
1671	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:11:47+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:12:00.561406+02	markdoe@gmail.com
1674	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:13:21+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:13:25.858897+02	grace.mulenga@ndola.health.zm
1676	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:13:34+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:13:35.349941+02	nkoleevans@gmail.com
1679	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:02+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:14:02.540259+02	nkoleevans@gmail.com
1687	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:22+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:14:23.803545+02	nkoleevans@gmail.com
1690	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:15:11+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:15:10.202426+02	lkampamba@gmail.com
1693	148	markdoe@gmail.com	5bee7b42fdc943b6912cd2144cb29175	2026-09-16 12:15:49+02	Session	\N	\N	Start	null	{"exp": 1789555560, "jti": "5bee7b42fdc943b6912cd2144cb29175", "lab": 3, "sub": "markdoe@gmail.com", "name": "Steven --", "role": 9, "mobile": "+260972441868", "userid": 148}	2026-09-16 12:16:01.733838+02	markdoe@gmail.com
1696	148	markdoe@gmail.com	5bee7b42fdc943b6912cd2144cb29175	2026-09-16 12:15:55+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:16:09.508728+02	markdoe@gmail.com
1697	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:16:13+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:16:13.912502+02	grace.mulenga@ndola.health.zm
1703	148	markdoe@gmail.com	5bee7b42fdc943b6912cd2144cb29175	2026-09-16 12:18:52+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:19:05.436522+02	markdoe@gmail.com
1706	151	peter.zulu@kitwe.health.zm	1a31c22c68304d9fbd7468cc0ec168bc	2026-09-16 12:24:07+02	Session	\N	\N	Start	null	{"exp": 1789556047, "jti": "1a31c22c68304d9fbd7468cc0ec168bc", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 12:24:07.945336+02	peter.zulu@kitwe.health.zm
1712	163	nkoleevans@gmail.com	908670d273ac4d63bbe23ea5b1b9c3e4	2026-09-16 12:25:05+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:25:05.972695+02	nkoleevans@gmail.com
1716	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:31:00+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:31:00.681171+02	nkoleevans@gmail.com
1724	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:33:19+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:33:19.923875+02	nkoleevans@gmail.com
1727	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:37:34+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:37:34.715632+02	nkoleevans@gmail.com
1735	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:35+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-16 12:38:35.723442+02	nkoleevans@gmail.com
1738	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:54+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:38:54.699432+02	nkoleevans@gmail.com
1741	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:39:05+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 12:39:06.111018+02	nkoleevans@gmail.com
1742	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:39:12+02	Round Evaluation	\N	\N	View - Allowed	null	null	2026-09-16 12:39:13.358508+02	nkoleevans@gmail.com
1749	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:39:48+02	Session	\N	\N	Start	null	{"exp": 1789556988, "jti": "7c4f6d6fccb44760b85bb8c31e7da05f", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 12:39:48.949053+02	peter.zulu@kitwe.health.zm
1752	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:40:00+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:40:01.414772+02	peter.zulu@kitwe.health.zm
1755	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:41:51+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:41:55.48995+02	lkampamba@gmail.com
1756	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:43:24+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:43:23.988167+02	lkampamba@gmail.com
1759	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:46:00+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:46:01.175126+02	peter.zulu@kitwe.health.zm
1764	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:46:48+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:46:48.715662+02	peter.zulu@kitwe.health.zm
1766	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:47:58+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:48:07.103871+02	lkampamba@gmail.com
1666	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:10:53+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:11:11.616184+02	markdoe@gmail.com
1667	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:11:07+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:11:24.100416+02	markdoe@gmail.com
1669	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:11:51+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:11:52.340816+02	nkoleevans@gmail.com
1682	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:06+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:14:06.977069+02	nkoleevans@gmail.com
1691	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:15:14+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:15:13.300656+02	lkampamba@gmail.com
1692	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:15:17+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:15:17.469557+02	lkampamba@gmail.com
1700	151	peter.zulu@kitwe.health.zm	bebb7189239d46e2bfef899d4704fcd1	2026-09-16 12:16:42+02	Session	\N	\N	Start	null	{"exp": 1789555602, "jti": "bebb7189239d46e2bfef899d4704fcd1", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 12:16:43.348029+02	peter.zulu@kitwe.health.zm
1708	163	nkoleevans@gmail.com	908670d273ac4d63bbe23ea5b1b9c3e4	2026-09-16 12:24:18+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:24:18.599495+02	nkoleevans@gmail.com
1709	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:24:33+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:24:32.839832+02	lkampamba@gmail.com
1710	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:24:41+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:24:41.154143+02	lkampamba@gmail.com
1715	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:30:57+02	Session	\N	\N	Start	null	{"exp": 1789556457, "jti": "d6a26d33034840878e4d0f3adedd139c", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 12:30:58.397946+02	nkoleevans@gmail.com
1725	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:37:16+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:37:17.511455+02	nkoleevans@gmail.com
1737	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:42+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:38:43.748619+02	nkoleevans@gmail.com
1740	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:39:01+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 12:39:02.177832+02	nkoleevans@gmail.com
1744	1	wanangwa@gmail.com	7fb7dcb1e660419e98ba0383618e2b11	2026-09-16 12:39:20+02	Session	\N	\N	Start	null	{"exp": 1789556965, "jti": "7fb7dcb1e660419e98ba0383618e2b11", "lab": null, "sub": "wanangwa@gmail.com", "name": "Wanangwa Doh", "role": 1, "mobile": "+260978989259", "userid": 1}	2026-09-16 12:39:28.795495+02	wanangwa@gmail.com
1745	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:39:29+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 12:39:30.081066+02	nkoleevans@gmail.com
1753	148	markdoe@gmail.com	5bee7b42fdc943b6912cd2144cb29175	2026-09-16 12:39:59+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:40:13.913552+02	markdoe@gmail.com
1760	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:46:06+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:46:07.001084+02	peter.zulu@kitwe.health.zm
1763	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:46:29+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:46:29.918445+02	peter.zulu@kitwe.health.zm
1670	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:11:56+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:11:56.692365+02	grace.mulenga@ndola.health.zm
1677	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:13:35+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:13:35.819527+02	nkoleevans@gmail.com
1680	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:02+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:14:03.619628+02	nkoleevans@gmail.com
1686	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:20+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:14:21.081138+02	nkoleevans@gmail.com
1689	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:14:52+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:14:55.390316+02	lkampamba@gmail.com
1698	148	markdoe@gmail.com	5bee7b42fdc943b6912cd2144cb29175	2026-09-16 12:16:10+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:16:24.577731+02	markdoe@gmail.com
1699	163	nkoleevans@gmail.com	1ead7c1706c64651ab15cf57aef58feb	2026-09-16 12:16:30+02	Session	\N	\N	Start	null	{"exp": 1789555590, "jti": "1ead7c1706c64651ab15cf57aef58feb", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 12:16:31.043784+02	nkoleevans@gmail.com
1704	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:19:17+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-16 12:19:16.582399+02	lkampamba@gmail.com
1713	151	peter.zulu@kitwe.health.zm	10f75b80514447b4947d83c273f207af	2026-09-16 12:25:49+02	Session	\N	\N	Start	null	{"exp": 1789556150, "jti": "10f75b80514447b4947d83c273f207af", "lab": 6, "sub": "peter.zulu@kitwe.health.zm", "name": "Vernon --", "role": 9, "mobile": "+260972579771", "userid": 151}	2026-09-16 12:25:55.524181+02	peter.zulu@kitwe.health.zm
1717	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:31:08+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-16 12:31:09.449409+02	nkoleevans@gmail.com
1718	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:31:33+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 12:31:33.651686+02	nkoleevans@gmail.com
1721	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:31:57+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 12:31:57.899377+02	nkoleevans@gmail.com
1726	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:37:30+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:37:30.711225+02	nkoleevans@gmail.com
1729	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:37:51+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:37:52.397711+02	nkoleevans@gmail.com
1731	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:00+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:38:00.581129+02	nkoleevans@gmail.com
1733	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:10+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:38:16.823871+02	nkoleevans@gmail.com
1736	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:39+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:38:39.980682+02	nkoleevans@gmail.com
1739	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:58+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 12:38:58.952973+02	nkoleevans@gmail.com
1743	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:39:26+02	Session	\N	\N	Start	null	{"exp": 1789556965, "jti": "cd7fdeb23b8847a494f62f5b1b52e1b2", "lab": 51, "sub": "lkampamba@gmail.com", "name": "Lombe Kampamba", "role": 9, "mobile": "0968656556", "userid": 176}	2026-09-16 12:39:28.430174+02	lkampamba@gmail.com
1746	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:39:32+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:39:32.020146+02	lkampamba@gmail.com
1750	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:39:50+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-16 12:39:51.510366+02	peter.zulu@kitwe.health.zm
1758	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:45:13+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:45:18.70353+02	lkampamba@gmail.com
1761	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:46:08+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:46:09.193655+02	peter.zulu@kitwe.health.zm
1765	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:47:12+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:47:13.323607+02	peter.zulu@kitwe.health.zm
1672	148	markdoe@gmail.com	7e79b50e2ef7445e8918a0aebc0fc5e1	2026-09-16 12:12:13+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:12:26.598721+02	markdoe@gmail.com
1673	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:13:01+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:13:04.197492+02	grace.mulenga@ndola.health.zm
1675	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 12:13:26+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:13:29.025732+02	peter.zulu@kitwe.health.zm
1681	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:04+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:14:05.240684+02	nkoleevans@gmail.com
1684	151	peter.zulu@kitwe.health.zm	c7348ee4ad7c4bdd9352779030468df9	2026-09-16 12:14:15+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:14:19.352158+02	peter.zulu@kitwe.health.zm
1685	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:14:20+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:14:19.785739+02	lkampamba@gmail.com
1688	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:14:41+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:14:40.165648+02	lkampamba@gmail.com
1702	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:18:47+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:18:47.148972+02	lkampamba@gmail.com
1707	163	nkoleevans@gmail.com	908670d273ac4d63bbe23ea5b1b9c3e4	2026-09-16 12:24:14+02	Session	\N	\N	Start	null	{"exp": 1789556054, "jti": "908670d273ac4d63bbe23ea5b1b9c3e4", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-16 12:24:14.985979+02	nkoleevans@gmail.com
1714	148	markdoe@gmail.com	5bee7b42fdc943b6912cd2144cb29175	2026-09-16 12:30:35+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:30:48.39947+02	markdoe@gmail.com
1720	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:31:44+02	Round Evaluation	\N	\N	View - Allowed	null	null	2026-09-16 12:31:45.00116+02	nkoleevans@gmail.com
1722	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:32:01+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 12:32:02.119337+02	nkoleevans@gmail.com
1728	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:37:47+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:37:48.309937+02	nkoleevans@gmail.com
1757	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:44:53+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:44:54.517397+02	peter.zulu@kitwe.health.zm
1678	150	grace.mulenga@ndola.health.zm	4b39fb5c46084373bab6ad435f021d8c	2026-09-16 12:13:40+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:13:40.573509+02	grace.mulenga@ndola.health.zm
1683	163	nkoleevans@gmail.com	4aa01c82fe034dba9598d26ef701a430	2026-09-16 12:14:11+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:14:12.303153+02	nkoleevans@gmail.com
1694	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:16:03+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:16:02.736265+02	lkampamba@gmail.com
1695	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:16:08+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:16:09.445338+02	lkampamba@gmail.com
1701	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:16:53+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-16 12:16:52.083266+02	lkampamba@gmail.com
1705	176	lkampamba@gmail.com	32d1a88632f34de2bdbb245bb7051a02	2026-09-16 12:19:21+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:19:22.286597+02	lkampamba@gmail.com
1711	163	nkoleevans@gmail.com	908670d273ac4d63bbe23ea5b1b9c3e4	2026-09-16 12:24:48+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:24:49.750229+02	nkoleevans@gmail.com
1719	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:31:35+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 12:31:36.366994+02	nkoleevans@gmail.com
1723	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:32:08+02	Round Evaluation	\N	\N	View - Allowed	null	null	2026-09-16 12:32:09.399318+02	nkoleevans@gmail.com
1730	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:37:56+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:37:57.197932+02	nkoleevans@gmail.com
1732	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:05+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:38:06.375708+02	nkoleevans@gmail.com
1734	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:38:20+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-09-16 12:38:21.21987+02	nkoleevans@gmail.com
1747	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:39:32+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-16 12:39:32.585803+02	nkoleevans@gmail.com
1748	163	nkoleevans@gmail.com	d6a26d33034840878e4d0f3adedd139c	2026-09-16 12:39:40+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-16 12:39:41.090027+02	nkoleevans@gmail.com
1751	176	lkampamba@gmail.com	cd7fdeb23b8847a494f62f5b1b52e1b2	2026-09-16 12:39:53+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:39:52.58333+02	lkampamba@gmail.com
1754	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:40:58+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-16 12:40:59.676966+02	peter.zulu@kitwe.health.zm
1762	151	peter.zulu@kitwe.health.zm	7c4f6d6fccb44760b85bb8c31e7da05f	2026-09-16 12:46:19+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-16 12:46:19.590785+02	peter.zulu@kitwe.health.zm
1767	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:28:47+02	Session	\N	\N	Start	null	{"exp": 1789721927, "jti": "e7b7fc92a10e439fb5b0912c9bc8089b", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-18 10:28:47.871041+02	nkoleevans@gmail.com
1768	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:28:59+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-18 10:28:59.630273+02	nkoleevans@gmail.com
1769	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:29:04+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-18 10:29:05.059868+02	nkoleevans@gmail.com
1770	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:29:09+02	Service List	\N	\N	View - Allowed	null	null	2026-09-18 10:29:09.922499+02	nkoleevans@gmail.com
1771	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:29:15+02	Method List	\N	\N	View - Allowed	null	null	2026-09-18 10:29:17.266874+02	nkoleevans@gmail.com
1772	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:29:23+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-09-18 10:29:23.671662+02	nkoleevans@gmail.com
1773	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:31:13+02	Provider List	\N	\N	View - Allowed	null	null	2026-09-18 10:31:13.688222+02	nkoleevans@gmail.com
1774	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:31:14+02	Scheme List	\N	\N	View - Allowed	null	null	2026-09-18 10:31:15.349738+02	nkoleevans@gmail.com
1775	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:31:15+02	Service List	\N	\N	View - Allowed	null	null	2026-09-18 10:31:15.848385+02	nkoleevans@gmail.com
1776	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:31:17+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-18 10:31:18.266476+02	nkoleevans@gmail.com
1777	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:33:55+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-18 10:33:55.982239+02	nkoleevans@gmail.com
1778	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:55:20+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-18 10:55:21.880732+02	nkoleevans@gmail.com
1779	163	nkoleevans@gmail.com	e7b7fc92a10e439fb5b0912c9bc8089b	2026-09-18 10:55:29+02	Users	\N	\N	View - Allowed	null	null	2026-09-18 10:55:29.969441+02	nkoleevans@gmail.com
1780	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:55:45+02	Session	\N	\N	Start	null	{"exp": 1789723545, "jti": "d6097fdfabc8443dbf47e48a15c2bf22", "lab": 15, "sub": "rachel.banda@kitwemicro.health.zm", "name": "Rachel Banda", "role": 9, "mobile": "+260970736889", "userid": 251}	2026-09-18 10:55:46.375601+02	rachel.banda@kitwemicro.health.zm
1781	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:55:54+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-18 10:55:54.697049+02	rachel.banda@kitwemicro.health.zm
1782	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:55:58+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-18 10:55:58.600584+02	rachel.banda@kitwemicro.health.zm
1783	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:55:59+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-18 10:55:59.652341+02	rachel.banda@kitwemicro.health.zm
1784	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:55:59+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-18 10:56:00.244091+02	rachel.banda@kitwemicro.health.zm
1785	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:00+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-18 10:56:00.890961+02	rachel.banda@kitwemicro.health.zm
1786	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:01+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-18 10:56:02.454698+02	rachel.banda@kitwemicro.health.zm
1787	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:02+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-18 10:56:03.265867+02	rachel.banda@kitwemicro.health.zm
1788	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:11+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-18 10:56:11.811963+02	rachel.banda@kitwemicro.health.zm
1790	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:16+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-18 10:56:17.463864+02	rachel.banda@kitwemicro.health.zm
1792	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 11:14:41+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-18 11:14:41.760429+02	rachel.banda@kitwemicro.health.zm
1789	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:14+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-18 10:56:15.250811+02	rachel.banda@kitwemicro.health.zm
1791	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 10:56:18+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-18 10:56:19.012092+02	rachel.banda@kitwemicro.health.zm
1793	251	rachel.banda@kitwemicro.health.zm	d6097fdfabc8443dbf47e48a15c2bf22	2026-09-18 11:14:46+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-18 11:14:46.957005+02	rachel.banda@kitwemicro.health.zm
1794	267	rachel.banda@kitwemicro.health.zm	fff02af578ff468e8a5a7d7151bdd765	2026-09-23 15:47:11+02	Session	\N	\N	Start	null	{"exp": 1790173031, "jti": "fff02af578ff468e8a5a7d7151bdd765", "lab": 15, "sub": "rachel.banda@kitwemicro.health.zm", "name": "Rachel Banda", "role": 9, "mobile": "+260979541479", "userid": 267}	2026-09-23 15:47:12.671126+02	rachel.banda@kitwemicro.health.zm
1795	267	rachel.banda@kitwemicro.health.zm	fff02af578ff468e8a5a7d7151bdd765	2026-09-23 15:47:14+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-23 15:47:15.453846+02	rachel.banda@kitwemicro.health.zm
1796	267	rachel.banda@kitwemicro.health.zm	fff02af578ff468e8a5a7d7151bdd765	2026-09-23 15:47:18+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 15:47:19.36123+02	rachel.banda@kitwemicro.health.zm
1797	267	rachel.banda@kitwemicro.health.zm	fff02af578ff468e8a5a7d7151bdd765	2026-09-23 15:47:22+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-23 15:47:22.597308+02	rachel.banda@kitwemicro.health.zm
1798	267	rachel.banda@kitwemicro.health.zm	fff02af578ff468e8a5a7d7151bdd765	2026-09-23 15:47:23+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-23 15:47:23.740416+02	rachel.banda@kitwemicro.health.zm
1799	267	rachel.banda@kitwemicro.health.zm	fff02af578ff468e8a5a7d7151bdd765	2026-09-23 16:08:04+02	My HIV-1 EID Results	\N	\N	View - Allowed	null	null	2026-09-23 16:08:06.286569+02	rachel.banda@kitwemicro.health.zm
1800	261	chanda.mwape@adch.health.zm	d566201afae4416798dc6b699080946f	2026-09-23 16:12:02+02	Session	\N	\N	Start	null	{"exp": 1790174522, "jti": "d566201afae4416798dc6b699080946f", "lab": 9, "sub": "chanda.mwape@adch.health.zm", "name": "Chanda Mwape", "role": 9, "mobile": "+260972493914", "userid": 261}	2026-09-23 16:12:02.686368+02	chanda.mwape@adch.health.zm
1801	261	chanda.mwape@adch.health.zm	d566201afae4416798dc6b699080946f	2026-09-23 16:12:04+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-23 16:12:04.922404+02	chanda.mwape@adch.health.zm
1802	261	chanda.mwape@adch.health.zm	d566201afae4416798dc6b699080946f	2026-09-23 16:12:07+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:12:08.094745+02	chanda.mwape@adch.health.zm
1803	261	chanda.mwape@adch.health.zm	d566201afae4416798dc6b699080946f	2026-09-23 16:12:10+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-23 16:12:11.20383+02	chanda.mwape@adch.health.zm
1804	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:17:39+02	Session	\N	\N	Start	null	{"exp": 1790174859, "jti": "a377a8d0334a485a8bb5c05de86c9043", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-09-23 16:17:39.980261+02	alanphiri@gmail.com
1805	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:17:43+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-23 16:17:43.762396+02	alanphiri@gmail.com
1806	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:17:46+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-23 16:17:47.549217+02	alanphiri@gmail.com
1807	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:17:51+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-23 16:17:51.710897+02	alanphiri@gmail.com
1808	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:17:54+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-23 16:17:54.90804+02	alanphiri@gmail.com
1809	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:17:58+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-23 16:17:59.520358+02	alanphiri@gmail.com
1810	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:18:03+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-23 16:18:03.606756+02	alanphiri@gmail.com
1811	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:18:53+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-23 16:18:54.503481+02	alanphiri@gmail.com
1812	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:18:55+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:18:56.401468+02	alanphiri@gmail.com
1813	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:18:58+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:18:59.132779+02	alanphiri@gmail.com
1814	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:01+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:19:02.507971+02	alanphiri@gmail.com
1815	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:04+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:19:05.06238+02	alanphiri@gmail.com
1816	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:06+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:19:07.400064+02	alanphiri@gmail.com
1817	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:09+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:19:10.36606+02	alanphiri@gmail.com
1818	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:12+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:19:12.66355+02	alanphiri@gmail.com
1819	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:14+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:19:15.217002+02	alanphiri@gmail.com
1820	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:17+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:19:17.626033+02	alanphiri@gmail.com
1821	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:19+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:19:20.528066+02	alanphiri@gmail.com
1822	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:22+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:19:22.788188+02	alanphiri@gmail.com
1823	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:25+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:19:26.40742+02	alanphiri@gmail.com
1824	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:28+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-23 16:19:28.907078+02	alanphiri@gmail.com
1825	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:31+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-23 16:19:32.211531+02	alanphiri@gmail.com
1826	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:55+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-23 16:19:55.966797+02	alanphiri@gmail.com
1827	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:19:58+02	Round Performance	\N	\N	View - Allowed	null	null	2026-09-23 16:19:58.577061+02	alanphiri@gmail.com
1831	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:13+02	Session	\N	\N	Start	null	{"exp": 1790253253, "jti": "7ba0afd8926542fbb97d88d0684a0617", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-09-24 14:04:13.906991+02	alanphiri@gmail.com
1834	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:28+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:29.301127+02	alanphiri@gmail.com
1835	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:30+02	My HIV-1 Viral Load Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:30.584274+02	alanphiri@gmail.com
1836	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:30+02	My Bacteriology Worksheets	\N	\N	View - Allowed	null	null	2026-09-24 14:04:31.414873+02	alanphiri@gmail.com
1837	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:31+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-24 14:04:32.033182+02	alanphiri@gmail.com
1838	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:32+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:32.620053+02	alanphiri@gmail.com
1839	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:38+02	TB Xpert XDR Result	\N	\N	View - Allowed	null	null	2026-09-24 14:04:39.454832+02	alanphiri@gmail.com
1864	258	alanphiri@gmail.com	3482415f24aa4e4cbc79d7783c15b2ca	2026-09-24 14:30:00+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-24 14:30:00.593377+02	alanphiri@gmail.com
1867	258	alanphiri@gmail.com	3482415f24aa4e4cbc79d7783c15b2ca	2026-09-24 14:32:45+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-24 14:32:45.848793+02	alanphiri@gmail.com
1872	258	alanphiri@gmail.com	25d1c2765723419bac11470de462fcd7	2026-09-24 14:38:00+02	Session	\N	\N	Start	null	{"exp": 1790255280, "jti": "25d1c2765723419bac11470de462fcd7", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-09-24 14:38:01.583577+02	alanphiri@gmail.com
1873	258	alanphiri@gmail.com	25d1c2765723419bac11470de462fcd7	2026-09-24 14:38:04+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:38:04.574746+02	alanphiri@gmail.com
1874	258	alanphiri@gmail.com	25d1c2765723419bac11470de462fcd7	2026-09-24 14:38:12+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-24 14:38:13.145147+02	alanphiri@gmail.com
1828	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:20:01+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-23 16:20:01.926273+02	alanphiri@gmail.com
1829	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:20:02+02	Round Performance	\N	\N	View - Allowed	null	null	2026-09-23 16:20:03.211249+02	alanphiri@gmail.com
1830	258	alanphiri@gmail.com	a377a8d0334a485a8bb5c05de86c9043	2026-09-23 16:20:05+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-09-23 16:20:05.836812+02	alanphiri@gmail.com
1832	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:16+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:16.97916+02	alanphiri@gmail.com
1833	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:21+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-24 14:04:21.874273+02	alanphiri@gmail.com
1840	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:42+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:42.940534+02	alanphiri@gmail.com
1841	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:43+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:43.846838+02	alanphiri@gmail.com
1842	258	alanphiri@gmail.com	7ba0afd8926542fbb97d88d0684a0617	2026-09-24 14:04:47+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:04:48.30386+02	alanphiri@gmail.com
1843	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:19:17+02	Session	\N	\N	Start	null	{"exp": 1790254157, "jti": "679b40ecf402438bbfdaeee209e85d46", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-09-24 14:19:17.681965+02	alanphiri@gmail.com
1844	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:19:38+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-24 14:19:39.661336+02	alanphiri@gmail.com
1845	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:20:50+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:20:50.845168+02	alanphiri@gmail.com
1846	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:21:09+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-24 14:21:10.439621+02	alanphiri@gmail.com
1847	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:21:16+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:21:16.746104+02	alanphiri@gmail.com
1848	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:21:22+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-24 14:21:22.903185+02	alanphiri@gmail.com
1849	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:22:52+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:22:53.143161+02	alanphiri@gmail.com
1850	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:23:38+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-09-24 14:23:38.764429+02	alanphiri@gmail.com
1851	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:25:58+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:25:58.629123+02	alanphiri@gmail.com
1852	258	alanphiri@gmail.com	679b40ecf402438bbfdaeee209e85d46	2026-09-24 14:26:12+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-24 14:26:13.244655+02	alanphiri@gmail.com
1853	0	admin@gmail.com	public	2026-09-24 14:27:01+02	Authentication	\N	\N	Unauthorised	null	null	2026-09-24 14:27:02.233968+02	admin@gmail.com
1854	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:27:16+02	Session	\N	\N	Start	null	{"exp": 1790254636, "jti": "cc901df542e24cba959dbba3fe6fe3ac", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-24 14:27:16.86412+02	nkoleevans@gmail.com
1855	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:27:22+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-24 14:27:22.665952+02	nkoleevans@gmail.com
1856	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:28:33+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-24 14:28:34.255051+02	nkoleevans@gmail.com
1857	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:28:45+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-24 14:28:46.168435+02	nkoleevans@gmail.com
1858	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:29:02+02	Review Enrollment	\N	\N	View - Allowed	null	null	2026-09-24 14:29:03.304953+02	nkoleevans@gmail.com
1859	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:29:07+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-09-24 14:29:08.493705+02	nkoleevans@gmail.com
1860	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:29:10+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-24 14:29:11.376264+02	nkoleevans@gmail.com
1861	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:29:20+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-09-24 14:29:20.757693+02	nkoleevans@gmail.com
1862	163	nkoleevans@gmail.com	cc901df542e24cba959dbba3fe6fe3ac	2026-09-24 14:29:41+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-24 14:29:41.755124+02	nkoleevans@gmail.com
1863	258	alanphiri@gmail.com	3482415f24aa4e4cbc79d7783c15b2ca	2026-09-24 14:29:56+02	Session	\N	\N	Start	null	{"exp": 1790254796, "jti": "3482415f24aa4e4cbc79d7783c15b2ca", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-09-24 14:29:57.224063+02	alanphiri@gmail.com
1865	258	alanphiri@gmail.com	3482415f24aa4e4cbc79d7783c15b2ca	2026-09-24 14:31:28+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-09-24 14:31:29.397785+02	alanphiri@gmail.com
1866	258	alanphiri@gmail.com	3482415f24aa4e4cbc79d7783c15b2ca	2026-09-24 14:32:40+02	My Performance	\N	\N	View - Allowed	null	null	2026-09-24 14:32:40.619805+02	alanphiri@gmail.com
1868	258	alanphiri@gmail.com	3482415f24aa4e4cbc79d7783c15b2ca	2026-09-24 14:34:12+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-09-24 14:34:12.969017+02	alanphiri@gmail.com
1869	163	nkoleevans@gmail.com	30b15b92b1644841b93e1ec71f08c30f	2026-09-24 14:34:31+02	Session	\N	\N	Start	null	{"exp": 1790255071, "jti": "30b15b92b1644841b93e1ec71f08c30f", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-09-24 14:34:32.459972+02	nkoleevans@gmail.com
1870	163	nkoleevans@gmail.com	30b15b92b1644841b93e1ec71f08c30f	2026-09-24 14:34:39+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-09-24 14:34:39.808203+02	nkoleevans@gmail.com
1871	163	nkoleevans@gmail.com	30b15b92b1644841b93e1ec71f08c30f	2026-09-24 14:34:42+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-09-24 14:34:43.391631+02	nkoleevans@gmail.com
1875	0	jane2003@company.co.zm	public	2026-10-21 15:41:32+02	Authentication	\N	\N	Unauthorised	null	null	2026-10-21 15:41:32.754283+02	jane2003@company.co.zm
1876	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:39+02	Session	\N	\N	Start	null	{"exp": 1792592079, "jti": "d67cae8df1bc4cd68d93799a966e1cb8", "lab": null, "sub": "head@cdl.moh.gov.zm", "name": "Mutende Wina", "role": 2, "mobile": "+260977004002", "userid": 6}	2026-10-21 15:44:40.296753+02	head@cdl.moh.gov.zm
1877	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:44+02	Users	\N	\N	View - Permission Denied	null	null	2026-10-21 15:44:44.742664+02	head@cdl.moh.gov.zm
1878	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:44+02	Role List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:44:45.531205+02	head@cdl.moh.gov.zm
1879	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:49+02	Provider List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:44:49.8374+02	head@cdl.moh.gov.zm
1880	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:50+02	Scheme List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:44:51.007064+02	head@cdl.moh.gov.zm
1881	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:51+02	Service List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:44:52.352307+02	head@cdl.moh.gov.zm
1882	6	head@cdl.moh.gov.zm	d67cae8df1bc4cd68d93799a966e1cb8	2026-10-21 15:44:52+02	Method List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:44:53.499687+02	head@cdl.moh.gov.zm
1883	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:10+02	Session	\N	\N	Start	null	{"exp": 1792592110, "jti": "ec2c7ec6f01843d3a32b58a2f4054f56", "lab": null, "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 3, "mobile": "+260978989259", "userid": 2}	2026-10-21 15:45:11.047914+02	nkoleevans@hotmail.com
1884	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:12+02	Users	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:13.047134+02	nkoleevans@hotmail.com
1885	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:13+02	Role List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:14.429933+02	nkoleevans@hotmail.com
1886	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:14+02	Data Migration	\N	\N	View - Allowed	null	null	2026-10-21 15:45:15.352578+02	nkoleevans@hotmail.com
1887	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:18+02	Review Stages	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:19.165807+02	nkoleevans@hotmail.com
1888	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:19+02	Statuses	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:19.740656+02	nkoleevans@hotmail.com
1889	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:21+02	Lab Type List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:21.640442+02	nkoleevans@hotmail.com
1890	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:21+02	PT Cycle Status List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:22.265713+02	nkoleevans@hotmail.com
1891	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:23+02	Province List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:24.115664+02	nkoleevans@hotmail.com
1892	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:24+02	District List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:24.770068+02	nkoleevans@hotmail.com
1893	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:27+02	Provider List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:27.77355+02	nkoleevans@hotmail.com
1894	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:28+02	Provider List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:28.725631+02	nkoleevans@hotmail.com
1895	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:31+02	Method List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:32.476335+02	nkoleevans@hotmail.com
1896	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:32+02	Method Sample List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:33.162146+02	nkoleevans@hotmail.com
1897	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:34+02	Laboratory List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:34.950483+02	nkoleevans@hotmail.com
1898	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:35+02	Laboratory Scheme List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:35.659768+02	nkoleevans@hotmail.com
1899	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:40+02	PT Cycle List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:41.091668+02	nkoleevans@hotmail.com
1900	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:45:41+02	Enrollment List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:45:41.758316+02	nkoleevans@hotmail.com
1901	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:47:07+02	Review Stages	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:10.301868+02	nkoleevans@hotmail.com
1902	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:47:08+02	Statuses	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:10.687288+02	nkoleevans@hotmail.com
1903	2	nkoleevans@hotmail.com	ec2c7ec6f01843d3a32b58a2f4054f56	2026-10-21 15:47:09+02	Lab Type List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:10.692974+02	nkoleevans@hotmail.com
1904	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:13+02	Session	\N	\N	Start	null	{"exp": 1792592233, "jti": "a24129a168ab4a2cae74066141a6b002", "lab": null, "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 3, "mobile": "+260978989259", "userid": 2}	2026-10-21 15:47:13.714153+02	nkoleevans@hotmail.com
1905	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:16+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:16.756632+02	nkoleevans@hotmail.com
1906	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:17+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:47:17.954682+02	nkoleevans@hotmail.com
1907	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:19+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:47:19.818785+02	nkoleevans@hotmail.com
1908	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:20+02	HIV-1 EID Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:47:20.759591+02	nkoleevans@hotmail.com
1909	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:21+02	Bacteriology Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:47:21.746098+02	nkoleevans@hotmail.com
1910	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:22+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-10-21 15:47:23.132545+02	nkoleevans@hotmail.com
1911	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:23+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:24.304986+02	nkoleevans@hotmail.com
1912	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:25+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:47:26.117378+02	nkoleevans@hotmail.com
1913	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:26+02	TB Xpert Ultra Result List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:27.307222+02	nkoleevans@hotmail.com
1914	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:27+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:47:28.091825+02	nkoleevans@hotmail.com
1915	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:29+02	Application List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:30.324135+02	nkoleevans@hotmail.com
1916	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:31+02	PT Cycle List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:31.61289+02	nkoleevans@hotmail.com
1917	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:31+02	Enrollment List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:32.174409+02	nkoleevans@hotmail.com
1918	2	nkoleevans@hotmail.com	a24129a168ab4a2cae74066141a6b002	2026-10-21 15:47:50+02	PT Cycle List	\N	\N	View - Permission Denied	null	null	2026-10-21 15:47:50.669013+02	nkoleevans@hotmail.com
1919	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:25+02	Session	\N	\N	Start	null	{"exp": 1792592305, "jti": "035160dceb974669b0c32d45a16b1520", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-10-21 15:48:26.15004+02	nkoleevans@gmail.com
1920	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:28+02	TB Xpert Ultra Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:48:29.346272+02	nkoleevans@gmail.com
1921	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:29+02	TB Xpert XDR Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:48:30.305206+02	nkoleevans@gmail.com
1922	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:30+02	HIV-1 Viral Load Result List	\N	\N	View - Allowed	null	null	2026-10-21 15:48:31.090895+02	nkoleevans@gmail.com
1923	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:32+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-10-21 15:48:33.273379+02	nkoleevans@gmail.com
1924	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:33+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-10-21 15:48:34.427906+02	nkoleevans@gmail.com
1925	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:44+02	Review Stages	\N	\N	View - Allowed	null	null	2026-10-21 15:48:45.082029+02	nkoleevans@gmail.com
1926	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:45+02	Statuses	\N	\N	View - Allowed	null	null	2026-10-21 15:48:45.716439+02	nkoleevans@gmail.com
1927	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:48:50+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-10-21 15:48:50.724756+02	nkoleevans@gmail.com
1928	163	nkoleevans@gmail.com	035160dceb974669b0c32d45a16b1520	2026-10-21 15:49:00+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 15:49:01.256489+02	nkoleevans@gmail.com
1934	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:32+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:49:32.546803+02	jane@gmail.com
1935	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:36+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-10-21 15:49:36.784847+02	jane@gmail.com
1937	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:49:58+02	Session	\N	\N	Start	null	{"exp": 1792592398, "jti": "85191af543c6469dac8de6bd1337b743", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-10-21 15:49:59.319196+02	nkoleevans@gmail.com
1938	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:50:00+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 15:50:01.52205+02	nkoleevans@gmail.com
1939	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:50:13+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-10-21 15:50:14.471597+02	nkoleevans@gmail.com
1940	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:50:14+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-10-21 15:50:15.163704+02	nkoleevans@gmail.com
1941	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:50:23+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 15:50:24.179917+02	nkoleevans@gmail.com
1942	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:50:32+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-10-21 15:50:33.177317+02	nkoleevans@gmail.com
1943	163	nkoleevans@gmail.com	85191af543c6469dac8de6bd1337b743	2026-10-21 15:50:42+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 15:50:42.609636+02	nkoleevans@gmail.com
1954	258	alanphiri@gmail.com	e6d8719291f447549466cf050f80e861	2026-10-21 15:53:51+02	Session	\N	\N	Start	null	{"exp": 1792592631, "jti": "e6d8719291f447549466cf050f80e861", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-10-21 15:53:52.593195+02	alanphiri@gmail.com
1955	258	alanphiri@gmail.com	e6d8719291f447549466cf050f80e861	2026-10-21 15:53:53+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:53:54.517335+02	alanphiri@gmail.com
1956	258	alanphiri@gmail.com	e6d8719291f447549466cf050f80e861	2026-10-21 15:53:58+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-10-21 15:53:58.951834+02	alanphiri@gmail.com
1959	258	alanphiri@gmail.com	e6d8719291f447549466cf050f80e861	2026-10-21 15:54:08+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:54:08.968085+02	alanphiri@gmail.com
1987	258	alanphiri@gmail.com	9fff98d6501a40d4b3117a24d93aaa03	2026-10-21 16:26:00+02	Session	\N	\N	Start	null	{"exp": 1792594560, "jti": "9fff98d6501a40d4b3117a24d93aaa03", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-10-21 16:26:00.732739+02	alanphiri@gmail.com
1929	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:18+02	Session	\N	\N	Start	null	{"exp": 1792592358, "jti": "76a68f9ae18447c28fc15fabe15a5b2b", "lab": 2, "sub": "jane@gmail.com", "name": "Jane Banda", "role": 9, "mobile": "+260970703338", "userid": 256}	2026-10-21 15:49:18.734822+02	jane@gmail.com
1930	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:21+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:49:21.669288+02	jane@gmail.com
1931	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:22+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-10-21 15:49:22.852397+02	jane@gmail.com
1932	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:25+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:49:25.860886+02	jane@gmail.com
1933	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:29+02	Review TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-10-21 15:49:29.866678+02	jane@gmail.com
1936	256	jane@gmail.com	76a68f9ae18447c28fc15fabe15a5b2b	2026-10-21 15:49:39+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:49:39.758198+02	jane@gmail.com
1944	267	rachel.banda@kitwemicro.health.zm	f78bf0a024774424b79a73799bb03fb5	2026-10-21 15:50:58+02	Session	\N	\N	Start	null	{"exp": 1792592458, "jti": "f78bf0a024774424b79a73799bb03fb5", "lab": 15, "sub": "rachel.banda@kitwemicro.health.zm", "name": "Rachel Banda", "role": 9, "mobile": "+260979541479", "userid": 267}	2026-10-21 15:50:58.730964+02	rachel.banda@kitwemicro.health.zm
1945	267	rachel.banda@kitwemicro.health.zm	f78bf0a024774424b79a73799bb03fb5	2026-10-21 15:50:59+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:51:00.526141+02	rachel.banda@kitwemicro.health.zm
1946	267	rachel.banda@kitwemicro.health.zm	f78bf0a024774424b79a73799bb03fb5	2026-10-21 15:51:02+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-10-21 15:51:03.285224+02	rachel.banda@kitwemicro.health.zm
1947	267	rachel.banda@kitwemicro.health.zm	f78bf0a024774424b79a73799bb03fb5	2026-10-21 15:51:04+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:51:05.101273+02	rachel.banda@kitwemicro.health.zm
1948	267	rachel.banda@kitwemicro.health.zm	f78bf0a024774424b79a73799bb03fb5	2026-10-21 15:51:06+02	My TB Xpert XDR Results	\N	\N	View - Allowed	null	null	2026-10-21 15:51:07.214022+02	rachel.banda@kitwemicro.health.zm
1949	267	rachel.banda@kitwemicro.health.zm	f78bf0a024774424b79a73799bb03fb5	2026-10-21 15:51:08+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:51:09.534891+02	rachel.banda@kitwemicro.health.zm
1972	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:07:22+02	PT Cycle	\N	\N	View - Allowed	null	null	2026-10-21 16:07:23.40762+02	nkoleevans@gmail.com
1973	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:08:43+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-10-21 16:08:44.027591+02	nkoleevans@gmail.com
1974	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:09:00+02	Enrollment List	\N	\N	View - Allowed	null	null	2026-10-21 16:09:00.796462+02	nkoleevans@gmail.com
1975	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:09:49+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-10-21 16:09:49.619288+02	nkoleevans@gmail.com
1977	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:11:12+02	Session	\N	\N	Start	null	{"exp": 1792593672, "jti": "1730f58c5220427c91a2c130be1f7172", "lab": 4, "sub": "alanphiri@gmail.com", "name": "Alan Phiri", "role": 9, "mobile": "+260977960898", "userid": 258}	2026-10-21 16:11:12.821037+02	alanphiri@gmail.com
1981	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:15:38+02	My Performance	\N	\N	View - Allowed	null	null	2026-10-21 16:15:39.312419+02	alanphiri@gmail.com
1982	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:15:41+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-10-21 16:15:42.277013+02	alanphiri@gmail.com
1983	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:20:53+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-10-21 16:20:54.446563+02	alanphiri@gmail.com
1984	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:23:37+02	My Performance	\N	\N	View - Allowed	null	null	2026-10-21 16:23:38.505762+02	alanphiri@gmail.com
1985	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:23:50+02	PT Performance Report	\N	\N	View - Allowed	null	null	2026-10-21 16:23:50.554502+02	alanphiri@gmail.com
1988	163	nkoleevans@gmail.com	ad218c8cf9284378ae8d0ca62f35a678	2026-10-21 16:26:27+02	Session	\N	\N	Start	null	{"exp": 1792594587, "jti": "ad218c8cf9284378ae8d0ca62f35a678", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-10-21 16:26:27.824735+02	nkoleevans@gmail.com
1989	163	nkoleevans@gmail.com	ad218c8cf9284378ae8d0ca62f35a678	2026-10-21 16:26:31+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 16:26:31.953775+02	nkoleevans@gmail.com
1990	163	nkoleevans@gmail.com	ad218c8cf9284378ae8d0ca62f35a678	2026-10-21 16:28:45+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-10-21 16:28:46.447815+02	nkoleevans@gmail.com
1991	163	nkoleevans@gmail.com	ad218c8cf9284378ae8d0ca62f35a678	2026-10-21 16:37:57+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-10-21 16:37:57.650299+02	nkoleevans@gmail.com
1950	163	nkoleevans@gmail.com	6ae4571038314757a5e58b54d2671f9e	2026-10-21 15:51:45+02	Session	\N	\N	Start	null	{"exp": 1792592505, "jti": "6ae4571038314757a5e58b54d2671f9e", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-10-21 15:51:46.28865+02	nkoleevans@gmail.com
1951	163	nkoleevans@gmail.com	6ae4571038314757a5e58b54d2671f9e	2026-10-21 15:51:51+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 15:51:51.730962+02	nkoleevans@gmail.com
1952	163	nkoleevans@gmail.com	6ae4571038314757a5e58b54d2671f9e	2026-10-21 15:52:16+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-10-21 15:52:16.68916+02	nkoleevans@gmail.com
1953	163	nkoleevans@gmail.com	6ae4571038314757a5e58b54d2671f9e	2026-10-21 15:52:53+02	Users	\N	\N	View - Allowed	null	null	2026-10-21 15:52:54.030955+02	nkoleevans@gmail.com
1957	258	alanphiri@gmail.com	e6d8719291f447549466cf050f80e861	2026-10-21 15:54:01+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 15:54:01.817141+02	alanphiri@gmail.com
1958	258	alanphiri@gmail.com	e6d8719291f447549466cf050f80e861	2026-10-21 15:54:05+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-10-21 15:54:06.505903+02	alanphiri@gmail.com
1960	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 15:59:58+02	Session	\N	\N	Start	null	{"exp": 1792592998, "jti": "362d11189d334c779047ecaf3b1c8e90", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-10-21 15:59:58.909932+02	nkoleevans@gmail.com
1961	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:00:46+02	Role List	\N	\N	View - Allowed	null	null	2026-10-21 16:00:47.108288+02	nkoleevans@gmail.com
1962	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:02:16+02	Province List	\N	\N	View - Allowed	null	null	2026-10-21 16:02:17.415302+02	nkoleevans@gmail.com
1963	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:02:17+02	District List	\N	\N	View - Allowed	null	null	2026-10-21 16:02:18.628224+02	nkoleevans@gmail.com
1964	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:02:28+02	Provider List	\N	\N	View - Allowed	null	null	2026-10-21 16:02:29.456083+02	nkoleevans@gmail.com
1965	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:03:06+02	Scheme List	\N	\N	View - Allowed	null	null	2026-10-21 16:03:07.20736+02	nkoleevans@gmail.com
1966	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:03:31+02	Service List	\N	\N	View - Allowed	null	null	2026-10-21 16:03:31.687928+02	nkoleevans@gmail.com
1967	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:03:45+02	Method List	\N	\N	View - Allowed	null	null	2026-10-21 16:03:45.822322+02	nkoleevans@gmail.com
1968	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:03:59+02	Method Sample List	\N	\N	View - Allowed	null	null	2026-10-21 16:04:00.019481+02	nkoleevans@gmail.com
1969	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:06:21+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-10-21 16:06:22.283576+02	nkoleevans@gmail.com
1970	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:06:42+02	Laboratory Scheme List	\N	\N	View - Allowed	null	null	2026-10-21 16:06:43.207778+02	nkoleevans@gmail.com
1971	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:07:16+02	PT Cycle List	\N	\N	View - Allowed	null	null	2026-10-21 16:07:16.885469+02	nkoleevans@gmail.com
1976	163	nkoleevans@gmail.com	362d11189d334c779047ecaf3b1c8e90	2026-10-21 16:09:52+02	Review PT Cycle	\N	\N	View - Allowed	null	null	2026-10-21 16:09:52.634479+02	nkoleevans@gmail.com
1978	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:11:29+02	My Enrolments	\N	\N	View - Allowed	null	null	2026-10-21 16:11:30.117859+02	alanphiri@gmail.com
1979	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:12:18+02	My TB Xpert Ultra Results	\N	\N	View - Allowed	null	null	2026-10-21 16:12:19.289244+02	alanphiri@gmail.com
1980	258	alanphiri@gmail.com	1730f58c5220427c91a2c130be1f7172	2026-10-21 16:12:43+02	TB Xpert Ultra Result	\N	\N	View - Allowed	null	null	2026-10-21 16:12:43.702629+02	alanphiri@gmail.com
1986	163	nkoleevans@gmail.com	4fb32a5aac95418abce02fc5de0e9f58	2026-10-21 16:25:32+02	Session	\N	\N	Start	null	{"exp": 1792594532, "jti": "4fb32a5aac95418abce02fc5de0e9f58", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-10-21 16:25:33.262728+02	nkoleevans@gmail.com
1992	0	admin@gmail.com	public	2026-11-14 03:29:56+02	Authentication	\N	\N	Unauthorised	null	null	2026-11-14 03:29:56.915227+02	admin@gmail.com
1993	0	nkoleevans@hotmail.com	public	2026-11-14 03:30:00+02	Authentication	\N	\N	Unauthorised	null	null	2026-11-14 03:30:00.807745+02	nkoleevans@hotmail.com
1994	0	nkoleevans@hotmail.com	public	2026-11-14 03:30:02+02	Authentication	\N	\N	Unauthorised	null	null	2026-11-14 03:30:02.996547+02	nkoleevans@hotmail.com
1995	0	nkoleevans@gmail.com	public	2026-11-14 03:30:13+02	Authentication	\N	\N	Unauthorised	null	null	2026-11-14 03:30:14.4697+02	nkoleevans@gmail.com
1996	0	nkoleevans@gmail.com	public	2026-11-14 03:36:08+02	Authentication	\N	\N	Unauthorised	null	null	2026-11-14 03:36:08.802763+02	nkoleevans@gmail.com
1997	2	nkoleevans@hotmail.com	0fec8b677c4245c5b65c927c81956460	2026-11-14 03:37:00+02	Session	\N	\N	Start	null	{"exp": 1794622020, "jti": "0fec8b677c4245c5b65c927c81956460", "lab": null, "sub": "nkoleevans@hotmail.com", "name": "Jane Doe", "role": 3, "mobile": "+260978989259", "userid": 2}	2026-11-14 03:37:00.81852+02	nkoleevans@hotmail.com
1998	2	nkoleevans@hotmail.com	0fec8b677c4245c5b65c927c81956460	2026-11-14 03:37:04+02	Laboratory List	\N	\N	View - Permission Denied	null	null	2026-11-14 03:37:05.444397+02	nkoleevans@hotmail.com
1999	2	nkoleevans@hotmail.com	0fec8b677c4245c5b65c927c81956460	2026-11-14 03:37:07+02	Laboratory Scheme List	\N	\N	View - Permission Denied	null	null	2026-11-14 03:37:09.263945+02	nkoleevans@hotmail.com
2000	2	nkoleevans@hotmail.com	0fec8b677c4245c5b65c927c81956460	2026-11-14 03:37:13+02	Laboratory List	\N	\N	View - Permission Denied	null	null	2026-11-14 03:37:14.222859+02	nkoleevans@hotmail.com
2001	163	nkoleevans@gmail.com	363b43d5261144b8975862c4c4da3197	2026-11-14 03:37:46+02	Session	\N	\N	Start	null	{"exp": 1794622066, "jti": "363b43d5261144b8975862c4c4da3197", "lab": null, "sub": "nkoleevans@gmail.com", "name": "John Doe", "role": 1, "mobile": "+260978989259", "userid": 163}	2026-11-14 03:37:47.058374+02	nkoleevans@gmail.com
2002	163	nkoleevans@gmail.com	363b43d5261144b8975862c4c4da3197	2026-11-14 03:37:49+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-11-14 03:37:51.648737+02	nkoleevans@gmail.com
2003	163	nkoleevans@gmail.com	363b43d5261144b8975862c4c4da3197	2026-11-14 03:47:34+02	Laboratory List	\N	\N	View - Allowed	null	null	2026-11-14 03:47:45.929243+02	nkoleevans@gmail.com
\.


--
-- Data for Name: bacteriology_ast_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bacteriology_ast_results (id, bacteriology_result_id, ast_method, row_no, antibiotic, zone_diameter, mic_reading, interpretation, created_at, created_by, updated_at, updated_by) FROM stdin;
1	20	disk_diffusion	1	AMIKACIN	23	\N	S	2026-09-18 11:43:51.073024+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
2	20	disk_diffusion	2	CEFTRIAXONE	24	\N	S	2026-09-18 11:43:51.075022+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
3	20	disk_diffusion	3	CIPROFLOXACIN	21	\N	S	2026-09-18 11:43:51.076023+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
4	20	disk_diffusion	4	GENTAMICIN	25.5	\N	S	2026-09-18 11:43:51.07702+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
5	20	disk_diffusion	5	MEROPENEM	27.5	\N	S	2026-09-18 11:43:51.078021+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
6	15	disk_diffusion	1	AMIKACIN	17	\N	S	2026-09-18 11:43:51.186575+02	rachel.banda@kitwemicro.health.zm	\N	\N
7	15	disk_diffusion	2	CEFTRIAXONE	14.5	\N	R	2026-09-18 11:43:51.187159+02	rachel.banda@kitwemicro.health.zm	\N	\N
8	15	disk_diffusion	3	CIPROFLOXACIN	25.5	\N	S	2026-09-18 11:43:51.187159+02	rachel.banda@kitwemicro.health.zm	\N	\N
9	15	disk_diffusion	4	GENTAMICIN	19.5	\N	S	2026-09-18 11:43:51.188166+02	rachel.banda@kitwemicro.health.zm	\N	\N
10	15	disk_diffusion	5	MEROPENEM	21.5	\N	S	2026-09-18 11:43:51.188166+02	rachel.banda@kitwemicro.health.zm	\N	\N
11	10	disk_diffusion	1	AMIKACIN	17	\N	S	2026-09-18 11:43:51.301465+02	rachel.banda@kitwemicro.health.zm	\N	\N
12	10	disk_diffusion	2	CEFTRIAXONE	14.5	\N	R	2026-09-18 11:43:51.301465+02	rachel.banda@kitwemicro.health.zm	\N	\N
13	10	disk_diffusion	3	CIPROFLOXACIN	25.5	\N	S	2026-09-18 11:43:51.302463+02	rachel.banda@kitwemicro.health.zm	\N	\N
14	10	disk_diffusion	4	GENTAMICIN	19.5	\N	S	2026-09-18 11:43:51.302463+02	rachel.banda@kitwemicro.health.zm	\N	\N
15	10	disk_diffusion	5	MEROPENEM	21.5	\N	S	2026-09-18 11:43:51.303467+02	rachel.banda@kitwemicro.health.zm	\N	\N
16	5	disk_diffusion	1	AMIKACIN	21.5	\N	S	2026-09-18 11:43:51.409043+02	davies.simukonda@lth.co.zm	\N	\N
17	5	disk_diffusion	2	CEFTRIAXONE	8.5	\N	R	2026-09-18 11:43:51.410044+02	davies.simukonda@lth.co.zm	\N	\N
18	5	disk_diffusion	3	CIPROFLOXACIN	19.5	\N	S	2026-09-18 11:43:51.411041+02	davies.simukonda@lth.co.zm	\N	\N
19	5	disk_diffusion	4	GENTAMICIN	24	\N	S	2026-09-18 11:43:51.411547+02	davies.simukonda@lth.co.zm	\N	\N
20	5	disk_diffusion	5	MEROPENEM	26	\N	S	2026-09-18 11:43:51.411547+02	davies.simukonda@lth.co.zm	\N	\N
21	35	disk_diffusion	1	AMIKACIN	23	\N	S	2026-09-18 11:43:52.007331+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
22	35	disk_diffusion	2	CEFTRIAXONE	24	\N	S	2026-09-18 11:43:52.007331+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
23	35	disk_diffusion	3	CIPROFLOXACIN	21	\N	S	2026-09-18 11:43:52.008325+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
24	35	disk_diffusion	4	GENTAMICIN	25.5	\N	S	2026-09-18 11:43:52.009324+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
25	35	disk_diffusion	5	MEROPENEM	27.5	\N	S	2026-09-18 11:43:52.009324+02	mwila.chibesa@ndolamicro.health.zm	\N	\N
26	30	disk_diffusion	1	AMIKACIN	17	\N	S	2026-09-18 11:43:52.08945+02	rachel.banda@kitwemicro.health.zm	\N	\N
27	30	disk_diffusion	2	CEFTRIAXONE	14.5	\N	R	2026-09-18 11:43:52.090462+02	rachel.banda@kitwemicro.health.zm	\N	\N
28	30	disk_diffusion	3	CIPROFLOXACIN	25.5	\N	S	2026-09-18 11:43:52.090462+02	rachel.banda@kitwemicro.health.zm	\N	\N
29	30	disk_diffusion	4	GENTAMICIN	19.5	\N	S	2026-09-18 11:43:52.090462+02	rachel.banda@kitwemicro.health.zm	\N	\N
30	30	disk_diffusion	5	MEROPENEM	21.5	\N	S	2026-09-18 11:43:52.091898+02	rachel.banda@kitwemicro.health.zm	\N	\N
31	25	disk_diffusion	1	AMIKACIN	17	\N	S	2026-09-18 11:43:52.157366+02	rachel.banda@kitwemicro.health.zm	\N	\N
32	25	disk_diffusion	2	CEFTRIAXONE	14.5	\N	R	2026-09-18 11:43:52.157366+02	rachel.banda@kitwemicro.health.zm	\N	\N
33	25	disk_diffusion	3	CIPROFLOXACIN	25.5	\N	S	2026-09-18 11:43:52.157366+02	rachel.banda@kitwemicro.health.zm	\N	\N
34	25	disk_diffusion	4	GENTAMICIN	19.5	\N	S	2026-09-18 11:43:52.158372+02	rachel.banda@kitwemicro.health.zm	\N	\N
35	25	disk_diffusion	5	MEROPENEM	21.5	\N	S	2026-09-18 11:43:52.158372+02	rachel.banda@kitwemicro.health.zm	\N	\N
36	40	disk_diffusion	1	AMIKACIN	21.5	\N	S	2026-09-18 11:43:52.222713+02	davies.simukonda@lth.co.zm	\N	\N
37	40	disk_diffusion	2	CEFTRIAXONE	8.5	\N	R	2026-09-18 11:43:52.224229+02	davies.simukonda@lth.co.zm	\N	\N
38	40	disk_diffusion	3	CIPROFLOXACIN	19.5	\N	S	2026-09-18 11:43:52.224229+02	davies.simukonda@lth.co.zm	\N	\N
39	40	disk_diffusion	4	GENTAMICIN	24	\N	S	2026-09-18 11:43:52.224229+02	davies.simukonda@lth.co.zm	\N	\N
40	40	disk_diffusion	5	MEROPENEM	26	\N	S	2026-09-18 11:43:52.225237+02	davies.simukonda@lth.co.zm	\N	\N
\.


--
-- Data for Name: bacteriology_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bacteriology_results (id, name, description, scheme_id, lab_id, service_id, enrollment_id, pt_cycle_id, method_id, method_sample_id, date_samples_received, receipt_temperature, sample_condition, sample_condition_reason, date_submitted, testing_not_done, testing_not_done_reason, gram_stain_reaction, gram_morphology, gram_morphology_other, microscopy_comment, organism_identified, identification_comment, ast_performed, ast_guideline, ast_disk_diffusion, ast_mic_method, ast_mic_method_other, comments, reported_by, reported_on, reviewed_by, reviewed_on, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
19	NHRTIBACT D01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT D01-26 for Ndola Teaching Hospital Microbiology	4	14	5	42	10	10	48	2026-06-16	4	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-06-26	Laboratory In-charge	2026-06-26	266	4	5	1	2026-09-18 11:43:51.057959+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.717222+02	wanangwa@gmail.com	2026-09-18 11:43:51.057959+02	quality@cdl.moh.gov.zm
16	NHRTIBACT A01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT A01-26 for Ndola Teaching Hospital Microbiology	4	14	5	42	10	10	45	2026-06-16	3.5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-06-26	Laboratory In-charge	2026-06-26	266	4	5	1	2026-09-18 11:43:50.994691+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.713717+02	wanangwa@gmail.com	2026-09-18 11:43:50.995693+02	quality@cdl.moh.gov.zm
18	NHRTIBACT C01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT C01-26 for Ndola Teaching Hospital Microbiology	4	14	5	42	10	10	47	2026-06-16	5	Suitable	\N	2026-06-26	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-06-26	Laboratory In-charge	2026-06-26	266	4	5	1	2026-09-18 11:43:51.03491+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.715719+02	wanangwa@gmail.com	2026-09-18 11:43:51.03491+02	quality@cdl.moh.gov.zm
17	NHRTIBACT B01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT B01-26 for Ndola Teaching Hospital Microbiology	4	14	5	42	10	10	46	2026-06-16	6	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus epidermidis	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-06-26	Laboratory In-charge	2026-06-26	266	4	5	1	2026-09-18 11:43:51.01608+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.713717+02	wanangwa@gmail.com	2026-09-18 11:43:51.017081+02	quality@cdl.moh.gov.zm
11	NHRTIBACT A01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT A01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	43	10	10	45	2026-06-16	5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.117144+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.710716+02	wanangwa@gmail.com	2026-09-18 11:43:51.118145+02	quality@cdl.moh.gov.zm
20	NHRTIBACT E01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT E01-26 for Ndola Teaching Hospital Microbiology	4	14	5	42	10	10	49	2026-06-16	6.5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Ndola Technologist	2026-06-26	Laboratory In-charge	2026-06-26	266	4	5	1	2026-09-18 11:43:51.089557+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.718233+02	wanangwa@gmail.com	2026-09-18 11:43:51.091064+02	quality@cdl.moh.gov.zm
12	NHRTIBACT B01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT B01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	43	10	10	46	2026-06-16	4	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.139748+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.711717+02	wanangwa@gmail.com	2026-09-18 11:43:51.139748+02	quality@cdl.moh.gov.zm
13	NHRTIBACT C01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT C01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	43	10	10	47	2026-06-16	6.5	Suitable	\N	2026-06-26	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.157802+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.712717+02	wanangwa@gmail.com	2026-09-18 11:43:51.157802+02	quality@cdl.moh.gov.zm
14	NHRTIBACT D01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT D01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	43	10	10	48	2026-06-16	5.5	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.173567+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.712717+02	wanangwa@gmail.com	2026-09-18 11:43:51.174558+02	quality@cdl.moh.gov.zm
6	NHRTIBACT A01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT A01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	44	10	11	50	2026-06-16	3.5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.221491+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.704691+02	wanangwa@gmail.com	2026-09-18 11:43:51.222293+02	quality@cdl.moh.gov.zm
8	NHRTIBACT C01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT C01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	44	10	11	52	2026-06-16	5	Suitable	\N	2026-06-26	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.26295+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.706202+02	wanangwa@gmail.com	2026-09-18 11:43:51.26295+02	quality@cdl.moh.gov.zm
9	NHRTIBACT D01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT D01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	44	10	11	53	2026-06-16	4	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.286226+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.70971+02	wanangwa@gmail.com	2026-09-18 11:43:51.286226+02	quality@cdl.moh.gov.zm
1	NHRTIBACT A01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey One 2026 panel sample NHRTIBACT A01-26 for Lusaka Trust Hospital Laboratory	4	16	5	45	10	11	50	2026-06-16	6.5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-06-26	Laboratory In-charge	2026-06-26	268	4	5	1	2026-09-18 11:43:51.333528+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.699181+02	wanangwa@gmail.com	2026-09-18 11:43:51.335032+02	quality@cdl.moh.gov.zm
3	NHRTIBACT C01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey One 2026 panel sample NHRTIBACT C01-26 for Lusaka Trust Hospital Laboratory	4	16	5	45	10	11	52	2026-06-16	4.5	Suitable	\N	2026-06-26	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-06-26	Laboratory In-charge	2026-06-26	268	4	5	1	2026-09-18 11:43:51.378662+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.70169+02	wanangwa@gmail.com	2026-09-18 11:43:51.378662+02	quality@cdl.moh.gov.zm
5	NHRTIBACT E01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey One 2026 panel sample NHRTIBACT E01-26 for Lusaka Trust Hospital Laboratory	4	16	5	45	10	11	54	2026-06-16	6	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Lusaka Technologist	2026-06-26	Laboratory In-charge	2026-06-26	268	4	5	1	2026-09-18 11:43:51.424723+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.703692+02	wanangwa@gmail.com	2026-09-18 11:43:51.426243+02	quality@cdl.moh.gov.zm
15	NHRTIBACT E01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT E01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	43	10	10	49	2026-06-16	4.5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.198883+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.713717+02	wanangwa@gmail.com	2026-09-18 11:43:51.198883+02	quality@cdl.moh.gov.zm
7	NHRTIBACT B01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT B01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	44	10	11	51	2026-06-16	6	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus epidermidis	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.24186+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.706202+02	wanangwa@gmail.com	2026-09-18 11:43:51.242866+02	quality@cdl.moh.gov.zm
10	NHRTIBACT E01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey One 2026 panel sample NHRTIBACT E01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	44	10	11	54	2026-06-16	6.5	Suitable	\N	2026-06-26	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Kitwe Technologist	2026-06-26	Laboratory In-charge	2026-06-26	267	4	5	1	2026-09-18 11:43:51.312977+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.70971+02	wanangwa@gmail.com	2026-09-18 11:43:51.312977+02	quality@cdl.moh.gov.zm
2	NHRTIBACT B01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey One 2026 panel sample NHRTIBACT B01-26 for Lusaka Trust Hospital Laboratory	4	16	5	45	10	11	51	2026-06-16	5.5	Unsuitable	Swab arrived dry, transport medium had leaked	2026-06-26	t	Swab arrived dry, transport medium had leaked	\N	\N	\N	\N	\N	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-06-26	Laboratory In-charge	2026-06-26	268	4	5	1	2026-09-18 11:43:51.356428+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.70169+02	wanangwa@gmail.com	2026-09-18 11:43:51.356428+02	quality@cdl.moh.gov.zm
4	NHRTIBACT D01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey One 2026 panel sample NHRTIBACT D01-26 for Lusaka Trust Hospital Laboratory	4	16	5	45	10	11	53	2026-06-16	3.5	Suitable	\N	2026-06-26	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-06-26	Laboratory In-charge	2026-06-26	268	4	5	1	2026-09-18 11:43:51.397475+02	quality@cdl.moh.gov.zm	Checked against the characterised strain	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.703692+02	wanangwa@gmail.com	2026-09-18 11:43:51.397475+02	quality@cdl.moh.gov.zm
33	NHRTIBACT C01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT C01-26 for Ndola Teaching Hospital Microbiology	4	14	5	46	11	10	47	2026-09-11	5	Suitable	\N	2026-09-13	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-09-13	Laboratory In-charge	2026-09-13	266	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.753269+02	wanangwa@gmail.com	2026-09-18 11:43:51.974963+02	mwila.chibesa@ndolamicro.health.zm
34	NHRTIBACT D01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT D01-26 for Ndola Teaching Hospital Microbiology	4	14	5	46	11	10	48	2026-09-11	4	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-09-13	Laboratory In-charge	2026-09-13	266	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.754272+02	wanangwa@gmail.com	2026-09-18 11:43:51.988304+02	mwila.chibesa@ndolamicro.health.zm
26	NHRTIBACT A01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT A01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	47	11	10	45	2026-09-11	5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.746257+02	wanangwa@gmail.com	2026-09-18 11:43:52.029688+02	rachel.banda@kitwemicro.health.zm
28	NHRTIBACT C01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT C01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	47	11	10	47	2026-09-11	6.5	Suitable	\N	2026-09-13	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.748272+02	wanangwa@gmail.com	2026-09-18 11:43:52.058398+02	rachel.banda@kitwemicro.health.zm
29	NHRTIBACT D01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT D01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	47	11	10	48	2026-09-11	5.5	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.749269+02	wanangwa@gmail.com	2026-09-18 11:43:52.070883+02	rachel.banda@kitwemicro.health.zm
21	NHRTIBACT A01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT A01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	48	11	11	50	2026-09-11	3.5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.741742+02	wanangwa@gmail.com	2026-09-18 11:43:52.104192+02	rachel.banda@kitwemicro.health.zm
23	NHRTIBACT C01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT C01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	48	11	11	52	2026-09-11	5	Suitable	\N	2026-09-13	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.743743+02	wanangwa@gmail.com	2026-09-18 11:43:52.132669+02	rachel.banda@kitwemicro.health.zm
24	NHRTIBACT D01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT D01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	48	11	11	53	2026-09-11	4	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.744745+02	wanangwa@gmail.com	2026-09-18 11:43:52.144499+02	rachel.banda@kitwemicro.health.zm
36	NHRTIBACT A01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey Two 2026 panel sample NHRTIBACT A01-26 for Lusaka Trust Hospital Laboratory	4	16	5	49	11	11	50	2026-09-11	6.5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-09-13	Laboratory In-charge	2026-09-13	268	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.755269+02	wanangwa@gmail.com	2026-09-18 11:43:52.173528+02	davies.simukonda@lth.co.zm
38	NHRTIBACT C01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey Two 2026 panel sample NHRTIBACT C01-26 for Lusaka Trust Hospital Laboratory	4	16	5	49	11	11	52	2026-09-11	4.5	Suitable	\N	2026-09-13	f	\N	Gram positive	Diplococci	\N	\N	Streptococcus agalactiae	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-09-13	Laboratory In-charge	2026-09-13	268	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.756779+02	wanangwa@gmail.com	2026-09-18 11:43:52.197735+02	davies.simukonda@lth.co.zm
39	NHRTIBACT D01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey Two 2026 panel sample NHRTIBACT D01-26 for Lusaka Trust Hospital Laboratory	4	16	5	49	11	11	53	2026-09-11	3.5	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-09-13	Laboratory In-charge	2026-09-13	268	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.756779+02	wanangwa@gmail.com	2026-09-18 11:43:52.209762+02	davies.simukonda@lth.co.zm
31	NHRTIBACT A01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT A01-26 for Ndola Teaching Hospital Microbiology	4	14	5	46	11	10	45	2026-09-11	3.5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Escherichia coli	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-09-13	Laboratory In-charge	2026-09-13	266	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.751269+02	wanangwa@gmail.com	2026-09-18 11:43:51.94689+02	mwila.chibesa@ndolamicro.health.zm
32	NHRTIBACT B01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT B01-26 for Ndola Teaching Hospital Microbiology	4	14	5	46	11	10	46	2026-09-11	6	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus epidermidis	\N	f	\N	f	\N	\N	\N	Ndola Technologist	2026-09-13	Laboratory In-charge	2026-09-13	266	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.75227+02	wanangwa@gmail.com	2026-09-18 11:43:51.958929+02	mwila.chibesa@ndolamicro.health.zm
35	NHRTIBACT E01-26 - Ndola Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT E01-26 for Ndola Teaching Hospital Microbiology	4	14	5	46	11	10	49	2026-09-11	6.5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Ndola Technologist	2026-09-13	Laboratory In-charge	2026-09-13	266	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.755269+02	wanangwa@gmail.com	2026-09-18 11:43:52.005325+02	mwila.chibesa@ndolamicro.health.zm
27	NHRTIBACT B01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT B01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	47	11	10	46	2026-09-11	4	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus aureus	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.747269+02	wanangwa@gmail.com	2026-09-18 11:43:52.045857+02	rachel.banda@kitwemicro.health.zm
30	NHRTIBACT E01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT E01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	47	11	10	49	2026-09-11	4.5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.750272+02	wanangwa@gmail.com	2026-09-18 11:43:52.08945+02	rachel.banda@kitwemicro.health.zm
22	NHRTIBACT B01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT B01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	48	11	11	51	2026-09-11	6	Suitable	\N	2026-09-13	f	\N	Gram positive	Cocci	\N	\N	Staphylococcus epidermidis	\N	f	\N	f	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.742749+02	wanangwa@gmail.com	2026-09-18 11:43:52.118094+02	rachel.banda@kitwemicro.health.zm
25	NHRTIBACT E01-26 - Kitwe Teaching Hospital Microbiology	Bacteriology Survey Two 2026 panel sample NHRTIBACT E01-26 for Kitwe Teaching Hospital Microbiology	4	15	5	48	11	11	54	2026-09-11	6.5	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Kitwe Technologist	2026-09-13	Laboratory In-charge	2026-09-13	267	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.744745+02	wanangwa@gmail.com	2026-09-18 11:43:52.156847+02	rachel.banda@kitwemicro.health.zm
37	NHRTIBACT B01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey Two 2026 panel sample NHRTIBACT B01-26 for Lusaka Trust Hospital Laboratory	4	16	5	49	11	11	51	2026-09-11	5.5	Unsuitable	Swab arrived dry, transport medium had leaked	2026-09-13	t	Swab arrived dry, transport medium had leaked	\N	\N	\N	\N	\N	\N	f	\N	f	\N	\N	\N	Lusaka Technologist	2026-09-13	Laboratory In-charge	2026-09-13	268	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.756779+02	wanangwa@gmail.com	2026-09-18 11:43:52.18817+02	davies.simukonda@lth.co.zm
40	NHRTIBACT E01-26 - Lusaka Trust Hospital Laboratory	Bacteriology Survey Two 2026 panel sample NHRTIBACT E01-26 for Lusaka Trust Hospital Laboratory	4	16	5	49	11	11	54	2026-09-11	6	Suitable	\N	2026-09-13	f	\N	Gram negative	Bacilli	\N	\N	Klebsiella pneumoniae	\N	t	CLSI	t	\N	\N	\N	Lusaka Technologist	2026-09-13	Laboratory In-charge	2026-09-13	268	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.762832+02	wanangwa@gmail.com	2026-09-18 11:43:52.222713+02	davies.simukonda@lth.co.zm
\.


--
-- Data for Name: districts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.districts (id, name, description, province_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Chililabombwe	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.648912+02	\N	\N	\N
2	Chingola	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.660966+02	\N	\N	\N
3	Kalulushi	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.674004+02	\N	\N	\N
4	Kitwe	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.678524+02	\N	\N	\N
5	Luanshya	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.681533+02	\N	\N	\N
6	Lufwanyama	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.685536+02	\N	\N	\N
7	Masaiti	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.689533+02	\N	\N	\N
8	Mpongwe	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.692532+02	\N	\N	\N
9	Mufulira	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.699055+02	\N	\N	\N
10	Ndola	\N	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.701572+02	\N	\N	\N
11	Chadiza	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.707122+02	\N	\N	\N
12	Chama	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.709129+02	\N	\N	\N
13	Chasefu	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.712659+02	\N	\N	\N
14	Chipangali	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.715658+02	\N	\N	\N
15	Chipata	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.720659+02	\N	\N	\N
16	Kasenengwa	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.724663+02	\N	\N	\N
17	Katete	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.728176+02	\N	\N	\N
18	Lumezi	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.735212+02	\N	\N	\N
19	Lundazi	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.740261+02	\N	\N	\N
20	Mambwe	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.745263+02	\N	\N	\N
21	Nyimba	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.750265+02	\N	\N	\N
22	Petauke	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.753262+02	\N	\N	\N
23	Sinda	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.756785+02	\N	\N	\N
24	Vubwi	\N	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.760823+02	\N	\N	\N
25	Itezhi-Tezhi	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.767353+02	\N	\N	\N
26	Kabwe	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.771858+02	\N	\N	\N
27	Kapiri Mposhi	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.774862+02	\N	\N	\N
28	Luano	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.779903+02	\N	\N	\N
29	Mkushi	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.781899+02	\N	\N	\N
30	Mumbwa	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.784902+02	\N	\N	\N
31	Ngabwe	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.788898+02	\N	\N	\N
32	Serenje	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.796921+02	\N	\N	\N
33	Shibuyunji	\N	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.801921+02	\N	\N	\N
34	Chibombo	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.803427+02	\N	\N	\N
35	Chilanga	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.806439+02	\N	\N	\N
36	Chirundu	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.807435+02	\N	\N	\N
37	Kafue	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.80995+02	\N	\N	\N
38	Luangwa	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.812464+02	\N	\N	\N
39	Lusaka	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.815772+02	\N	\N	\N
40	Rufunsa	\N	5	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.81777+02	\N	\N	\N
41	Choma	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.819773+02	\N	\N	\N
42	Gwembe	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.823278+02	\N	\N	\N
43	Kalomo	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.824284+02	\N	\N	\N
44	Kazungula	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.830315+02	\N	\N	\N
45	Livingstone	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.833828+02	\N	\N	\N
46	Mazabuka	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.840349+02	\N	\N	\N
47	Monze	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.847863+02	\N	\N	\N
48	Namwala	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.857386+02	\N	\N	\N
49	Pemba	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.859384+02	\N	\N	\N
50	Siavonga	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.862419+02	\N	\N	\N
51	Sinazongwe	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.865753+02	\N	\N	\N
52	Zimba	\N	9	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.872278+02	\N	\N	\N
53	Isoka	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.881599+02	\N	\N	\N
54	Kanchibiya	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.885606+02	\N	\N	\N
55	Lavushimanda	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.890119+02	\N	\N	\N
56	Mafinga	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.893117+02	\N	\N	\N
57	Mpika	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.895115+02	\N	\N	\N
58	Nakonde	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.897631+02	\N	\N	\N
59	Shiwang'andu	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.900146+02	\N	\N	\N
60	Chinsali	\N	6	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.904145+02	\N	\N	\N
61	Kasama	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.90866+02	\N	\N	\N
62	Chilubi	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.913171+02	\N	\N	\N
63	Kaputa	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.920725+02	\N	\N	\N
64	Luwingu	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.923734+02	\N	\N	\N
65	Mbala	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.927735+02	\N	\N	\N
66	Mporokoso	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.934768+02	\N	\N	\N
67	Mpulungu	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.938768+02	\N	\N	\N
68	Nsama	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.94128+02	\N	\N	\N
69	Senga Hill	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.944282+02	\N	\N	\N
70	Lunte	\N	7	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.949799+02	\N	\N	\N
71	Mansa	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.956313+02	\N	\N	\N
72	Chembe	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.959313+02	\N	\N	\N
73	Chiengi	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.965831+02	\N	\N	\N
74	Chipili	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.968854+02	\N	\N	\N
75	Kawambwa	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.972365+02	\N	\N	\N
76	Lunga	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.974363+02	\N	\N	\N
77	Milenge	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.977876+02	\N	\N	\N
78	Mwansabombwe	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.979875+02	\N	\N	\N
79	Mwense	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.981876+02	\N	\N	\N
80	Nchelenge	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.982875+02	\N	\N	\N
81	Samfya	\N	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.985876+02	\N	\N	\N
82	Mongu	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.988382+02	\N	\N	\N
83	Kalabo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.991385+02	\N	\N	\N
84	Kaoma	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.994387+02	\N	\N	\N
85	Limulunga	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.997385+02	\N	\N	\N
86	Lukulu	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:07.999889+02	\N	\N	\N
87	Mitete	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.002899+02	\N	\N	\N
88	Nalolo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.005407+02	\N	\N	\N
89	Nkeyema	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.00741+02	\N	\N	\N
90	Senanga	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.009408+02	\N	\N	\N
91	Sesheke	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.012407+02	\N	\N	\N
92	Shangombo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.016913+02	\N	\N	\N
93	Sikongo	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.019921+02	\N	\N	\N
94	Sioma	\N	10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.02192+02	\N	\N	\N
95	Kabompo	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.023429+02	\N	\N	\N
96	Chavuma	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.027944+02	\N	\N	\N
97	Ikelenge	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.030455+02	\N	\N	\N
98	Kalumbila	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.032455+02	\N	\N	\N
99	Kasempa	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.036476+02	\N	\N	\N
100	Manyinga	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.040475+02	\N	\N	\N
101	Mufumbwe	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.042478+02	\N	\N	\N
102	Mwinilunga	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.045989+02	\N	\N	\N
103	Solwezi	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.048988+02	\N	\N	\N
104	Zambezi	\N	8	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:08.050497+02	\N	\N	\N
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollments (id, name, description, scheme_id, lab_id, service_id, method_id, pt_cycle_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, samples_received_at, samples_received_by) FROM stdin;
1	DTS Round One 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - Ultra	\N	1	1	2	1	1	255	4	5	1	2026-09-18 11:43:44.12462+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.830794+02	musachoolwe@gmail.com	2026-09-18 11:43:44.505861+02	musachoolwe@gmail.com	2026-05-17 09:00:00+02	musachoolwe@gmail.com
18	DTS Round Two 2026 - Ndola Teaching Hospital Lab - Ndola Teaching Hospital Lab - Ultra	\N	1	5	2	1	2	259	4	5	1	2026-09-18 11:43:46.121829+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.052778+02	grace.mulenga@ndola.health.zm	2026-09-18 11:43:46.23597+02	grace.mulenga@ndola.health.zm	2026-09-11 09:00:00+02	grace.mulenga@ndola.health.zm
10	DTS Round One 2026 - Kitwe Central Hospital Lab - Kitwe Central Hospital Lab - XDR	\N	1	6	2	2	1	260	4	5	1	2026-09-18 11:43:44.046011+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.87964+02	peter.zulu@kitwe.health.zm	2026-09-18 11:43:44.238854+02	peter.zulu@kitwe.health.zm	2026-05-17 09:00:00+02	peter.zulu@kitwe.health.zm
9	DTS Round One 2026 - Kitwe Central Hospital Lab - Kitwe Central Hospital Lab - Ultra	\N	1	6	2	1	1	260	4	5	1	2026-09-18 11:43:44.057015+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.87913+02	peter.zulu@kitwe.health.zm	2026-09-18 11:43:44.270898+02	peter.zulu@kitwe.health.zm	2026-05-17 09:00:00+02	peter.zulu@kitwe.health.zm
8	DTS Round One 2026 - Ndola Teaching Hospital Lab - Ndola Teaching Hospital Lab - Ultra	\N	1	5	2	1	1	259	4	5	1	2026-09-18 11:43:44.064016+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.870661+02	grace.mulenga@ndola.health.zm	2026-09-18 11:43:44.29349+02	grace.mulenga@ndola.health.zm	2026-05-17 09:00:00+02	grace.mulenga@ndola.health.zm
7	DTS Round One 2026 - UTH New Lab - UTH New Lab - XDR	\N	1	4	2	2	1	258	4	5	1	2026-09-18 11:43:44.071522+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.861154+02	alanphiri@gmail.com	2026-09-18 11:43:44.327794+02	alanphiri@gmail.com	2026-05-17 09:00:00+02	alanphiri@gmail.com
6	DTS Round One 2026 - UTH New Lab - UTH New Lab - Ultra	\N	1	4	2	1	1	258	4	5	1	2026-09-18 11:43:44.084409+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.860164+02	alanphiri@gmail.com	2026-09-18 11:43:44.359674+02	alanphiri@gmail.com	2026-05-17 09:00:00+02	alanphiri@gmail.com
5	DTS Round One 2026 - Private Lab 1 - Private Lab 1 - Ultra	\N	1	3	2	1	1	257	4	5	1	2026-09-18 11:43:44.093919+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.85137+02	markdoe@gmail.com	2026-09-18 11:43:44.39278+02	markdoe@gmail.com	2026-05-17 09:00:00+02	markdoe@gmail.com
4	DTS Round One 2026 - Private Lab 1 - Private Lab 1 - Ziehl-Neelsen	\N	1	3	1	3	1	257	4	5	1	2026-09-18 11:43:44.101922+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.850369+02	markdoe@gmail.com	2026-09-18 11:43:44.419942+02	markdoe@gmail.com	2026-05-17 09:00:00+02	markdoe@gmail.com
3	DTS Round One 2026 - Levy Lusaka Laboratory - Levy Lusaka Laboratory - Ultra	\N	1	2	2	1	1	256	4	5	1	2026-09-18 11:43:44.108928+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.842841+02	jane@gmail.com	2026-09-18 11:43:44.446515+02	jane@gmail.com	2026-05-17 09:00:00+02	jane@gmail.com
2	DTS Round One 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - XDR	\N	1	1	2	2	1	255	4	5	1	2026-09-18 11:43:44.1166+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.833306+02	musachoolwe@gmail.com	2026-09-18 11:43:44.484715+02	musachoolwe@gmail.com	2026-05-17 09:00:00+02	musachoolwe@gmail.com
19	DTS Round Two 2026 - Kitwe Central Hospital Lab - Kitwe Central Hospital Lab - Ultra	\N	1	6	2	1	2	260	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.059786+02	peter.zulu@kitwe.health.zm	\N	\N	\N	\N
20	DTS Round Two 2026 - Kitwe Central Hospital Lab - Kitwe Central Hospital Lab - XDR	\N	1	6	2	2	2	260	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.060787+02	peter.zulu@kitwe.health.zm	\N	\N	\N	\N
12	DTS Round Two 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - XDR	\N	1	1	2	2	2	255	4	5	1	2026-09-18 11:43:46.158415+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.00892+02	musachoolwe@gmail.com	2026-09-18 11:43:46.37301+02	musachoolwe@gmail.com	2026-09-11 09:00:00+02	musachoolwe@gmail.com
11	DTS Round Two 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - Ultra	\N	1	1	2	1	2	255	4	5	1	2026-09-18 11:43:46.16442+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.007922+02	musachoolwe@gmail.com	2026-09-18 11:43:46.395546+02	musachoolwe@gmail.com	2026-09-11 09:00:00+02	musachoolwe@gmail.com
21	DTS Round One 2027 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - Ultra	\N	1	1	2	1	3	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.899815+02	musachoolwe@gmail.com	\N	\N	\N	\N
22	DTS Round One 2027 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - XDR	\N	1	1	2	2	3	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.900817+02	musachoolwe@gmail.com	\N	\N	\N	\N
23	DTS Round One 2027 - Levy Lusaka Laboratory - Levy Lusaka Laboratory - Ultra	\N	1	2	2	1	3	256	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.911339+02	jane@gmail.com	\N	\N	\N	\N
26	HIV-1 VL Round One 2026 - Chipata Central Hospital Lab - Chipata Central Hospital Lab - Roche Cobas 6800	\N	2	10	3	6	5	262	4	5	1	2026-09-18 11:43:47.086198+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.993911+02	foster.tembo@chipata.health.zm	2026-09-18 11:43:47.232624+02	foster.tembo@chipata.health.zm	2026-06-06 09:00:00+02	foster.tembo@chipata.health.zm
25	HIV-1 VL Round One 2026 - Arthur Davison Childrens Hospital Lab - Arthur Davison Childrens Hospital Lab - Abbott m2000	\N	2	9	3	5	5	261	4	5	1	2026-09-18 11:43:47.0942+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.984905+02	chanda.mwape@adch.health.zm	2026-09-18 11:43:47.257193+02	chanda.mwape@adch.health.zm	2026-06-06 09:00:00+02	chanda.mwape@adch.health.zm
17	DTS Round Two 2026 - UTH New Lab - UTH New Lab - XDR	\N	1	4	2	2	2	258	4	5	1	2026-09-18 11:43:46.128357+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.045777+02	alanphiri@gmail.com	2026-09-18 11:43:46.260981+02	alanphiri@gmail.com	2026-09-11 09:00:00+02	alanphiri@gmail.com
16	DTS Round Two 2026 - UTH New Lab - UTH New Lab - Ultra	\N	1	4	2	1	2	258	4	5	1	2026-09-18 11:43:46.134373+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.045777+02	alanphiri@gmail.com	2026-09-18 11:43:46.282105+02	alanphiri@gmail.com	2026-09-11 09:00:00+02	alanphiri@gmail.com
15	DTS Round Two 2026 - Private Lab 1 - Private Lab 1 - Ultra	\N	1	3	2	1	2	257	4	5	1	2026-09-18 11:43:46.139884+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.035768+02	markdoe@gmail.com	2026-09-18 11:43:46.310118+02	markdoe@gmail.com	2026-09-11 09:00:00+02	markdoe@gmail.com
14	DTS Round Two 2026 - Private Lab 1 - Private Lab 1 - Ziehl-Neelsen	\N	1	3	1	3	2	257	4	5	1	2026-09-18 11:43:46.146046+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.035264+02	markdoe@gmail.com	2026-09-18 11:43:46.332628+02	markdoe@gmail.com	2026-09-11 09:00:00+02	markdoe@gmail.com
13	DTS Round Two 2026 - Levy Lusaka Laboratory - Levy Lusaka Laboratory - Ultra	\N	1	2	2	1	2	256	4	5	1	2026-09-18 11:43:46.152809+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.020395+02	jane@gmail.com	2026-09-18 11:43:46.351962+02	jane@gmail.com	2026-09-11 09:00:00+02	jane@gmail.com
24	HIV-1 VL Round One 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - Hologic Panther	\N	2	1	3	7	5	255	4	5	1	2026-09-18 11:43:47.102432+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.949353+02	musachoolwe@gmail.com	2026-09-18 11:43:47.280763+02	musachoolwe@gmail.com	2026-06-06 09:00:00+02	musachoolwe@gmail.com
41	HIV-1 EID Round Two 2026 - Mongu Provincial Hospital Lab - Mongu Provincial Hospital Lab - GeneXpert HIV-1 Qual	\N	3	13	4	9	8	265	4	5	1	2026-09-18 11:43:49.983747+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:49.945956+02	situmbeko.imwiko@mongu.health.zm	2026-09-18 11:43:50.082878+02	situmbeko.imwiko@mongu.health.zm	2026-09-12 09:00:00+02	situmbeko.imwiko@mongu.health.zm
28	HIV-1 VL Round One 2026 - Kabwe General Hospital Lab - Kabwe General Hospital Lab - Hologic Panther	\N	2	11	3	7	5	263	4	5	1	2026-09-18 11:43:47.066652+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.003908+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:47.186021+02	idah.nsofwa@kabwe.health.zm	2026-06-06 09:00:00+02	idah.nsofwa@kabwe.health.zm
27	HIV-1 VL Round One 2026 - Kabwe General Hospital Lab - Kabwe General Hospital Lab - Abbott m2000	\N	2	11	3	5	5	263	4	5	1	2026-09-18 11:43:47.07517+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.00291+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:47.209557+02	idah.nsofwa@kabwe.health.zm	2026-06-06 09:00:00+02	idah.nsofwa@kabwe.health.zm
37	HIV-1 EID Round One 2026 - Mongu Provincial Hospital Lab - Mongu Provincial Hospital Lab - GeneXpert HIV-1 Qual	\N	3	13	4	9	7	265	4	5	1	2026-09-18 11:43:48.859143+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.81367+02	situmbeko.imwiko@mongu.health.zm	2026-09-18 11:43:48.974491+02	situmbeko.imwiko@mongu.health.zm	2026-06-16 09:00:00+02	situmbeko.imwiko@mongu.health.zm
36	HIV-1 EID Round One 2026 - Mansa General Hospital Lab - Mansa General Hospital Lab - Cobas 4800	\N	3	12	4	8	7	264	4	5	1	2026-09-18 11:43:48.866648+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.806155+02	chola.mumba@mansa.health.zm	2026-09-18 11:43:48.994584+02	chola.mumba@mansa.health.zm	2026-06-16 09:00:00+02	chola.mumba@mansa.health.zm
35	HIV-1 EID Round One 2026 - Kabwe General Hospital Lab - Kabwe General Hospital Lab - Cobas 4800	\N	3	11	4	8	7	263	4	5	1	2026-09-18 11:43:48.873409+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.800126+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:49.028197+02	idah.nsofwa@kabwe.health.zm	2026-06-16 09:00:00+02	idah.nsofwa@kabwe.health.zm
34	HIV-1 EID Round One 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - GeneXpert HIV-1 Qual	\N	3	1	4	9	7	255	4	5	1	2026-09-18 11:43:48.881646+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.746958+02	musachoolwe@gmail.com	2026-09-18 11:43:49.051789+02	musachoolwe@gmail.com	2026-06-16 09:00:00+02	musachoolwe@gmail.com
33	HIV-1 VL Round Two 2026 - Kabwe General Hospital Lab - Kabwe General Hospital Lab - Hologic Panther	\N	2	11	3	7	6	263	4	5	1	2026-09-18 11:43:48.185171+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.131672+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:48.291593+02	idah.nsofwa@kabwe.health.zm	2026-09-12 09:00:00+02	idah.nsofwa@kabwe.health.zm
32	HIV-1 VL Round Two 2026 - Kabwe General Hospital Lab - Kabwe General Hospital Lab - Abbott m2000	\N	2	11	3	5	6	263	4	5	1	2026-09-18 11:43:48.195173+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.131672+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:48.317152+02	idah.nsofwa@kabwe.health.zm	2026-09-12 09:00:00+02	idah.nsofwa@kabwe.health.zm
31	HIV-1 VL Round Two 2026 - Chipata Central Hospital Lab - Chipata Central Hospital Lab - Roche Cobas 6800	\N	2	10	3	6	6	262	4	5	1	2026-09-18 11:43:48.206593+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.125673+02	foster.tembo@chipata.health.zm	2026-09-18 11:43:48.337665+02	foster.tembo@chipata.health.zm	2026-09-12 09:00:00+02	foster.tembo@chipata.health.zm
30	HIV-1 VL Round Two 2026 - Arthur Davison Childrens Hospital Lab - Arthur Davison Childrens Hospital Lab - Abbott m2000	\N	2	9	3	5	6	261	4	5	1	2026-09-18 11:43:48.214596+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.116675+02	chanda.mwape@adch.health.zm	2026-09-18 11:43:48.362779+02	chanda.mwape@adch.health.zm	2026-09-12 09:00:00+02	chanda.mwape@adch.health.zm
29	HIV-1 VL Round Two 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - Hologic Panther	\N	2	1	3	7	6	255	4	5	1	2026-09-18 11:43:48.223126+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.087151+02	musachoolwe@gmail.com	2026-09-18 11:43:48.383824+02	musachoolwe@gmail.com	2026-09-12 09:00:00+02	musachoolwe@gmail.com
40	HIV-1 EID Round Two 2026 - Mansa General Hospital Lab - Mansa General Hospital Lab - Cobas 4800	\N	3	12	4	8	8	264	4	5	1	2026-09-18 11:43:49.993836+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:49.937957+02	chola.mumba@mansa.health.zm	2026-09-18 11:43:50.103463+02	chola.mumba@mansa.health.zm	2026-09-12 09:00:00+02	chola.mumba@mansa.health.zm
39	HIV-1 EID Round Two 2026 - Kabwe General Hospital Lab - Kabwe General Hospital Lab - Cobas 4800	\N	3	11	4	8	8	263	4	5	1	2026-09-18 11:43:50.002968+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:49.931423+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:50.125681+02	idah.nsofwa@kabwe.health.zm	2026-09-12 09:00:00+02	idah.nsofwa@kabwe.health.zm
38	HIV-1 EID Round Two 2026 - Levy Mwanawasa University Teaching Hospital - Levy Mwanawasa University Teaching Hospital - GeneXpert HIV-1 Qual	\N	3	1	4	9	8	255	4	5	1	2026-09-18 11:43:50.009973+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:49.857952+02	musachoolwe@gmail.com	2026-09-18 11:43:50.144615+02	musachoolwe@gmail.com	2026-09-12 09:00:00+02	musachoolwe@gmail.com
43	Bacteriology Survey One 2026 - Kitwe Teaching Hospital Microbiology - Kitwe Teaching Hospital Microbiology - Manual	\N	4	15	5	10	10	267	4	5	1	2026-09-18 11:43:50.669852+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.617775+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:50.808291+02	rachel.banda@kitwemicro.health.zm	2026-06-16 09:00:00+02	rachel.banda@kitwemicro.health.zm
42	Bacteriology Survey One 2026 - Ndola Teaching Hospital Microbiology - Ndola Teaching Hospital Microbiology - Manual	\N	4	14	5	10	10	266	4	5	1	2026-09-18 11:43:50.681118+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.611776+02	mwila.chibesa@ndolamicro.health.zm	2026-09-18 11:43:50.828605+02	mwila.chibesa@ndolamicro.health.zm	2026-06-16 09:00:00+02	mwila.chibesa@ndolamicro.health.zm
45	Bacteriology Survey One 2026 - Lusaka Trust Hospital Laboratory - Lusaka Trust Hospital Laboratory - Automated	\N	4	16	5	11	10	268	4	5	1	2026-09-18 11:43:50.653869+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.625285+02	davies.simukonda@lth.co.zm	2026-09-18 11:43:50.755212+02	davies.simukonda@lth.co.zm	2026-06-16 09:00:00+02	davies.simukonda@lth.co.zm
44	Bacteriology Survey One 2026 - Kitwe Teaching Hospital Microbiology - Kitwe Teaching Hospital Microbiology - Automated	\N	4	15	5	11	10	267	4	5	1	2026-09-18 11:43:50.663753+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.618776+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:50.784846+02	rachel.banda@kitwemicro.health.zm	2026-06-16 09:00:00+02	rachel.banda@kitwemicro.health.zm
47	Bacteriology Survey Two 2026 - Kitwe Teaching Hospital Microbiology - Kitwe Teaching Hospital Microbiology - Manual	\N	4	15	5	10	11	267	4	5	1	2026-09-18 11:43:51.716612+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.665843+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:51.869464+02	rachel.banda@kitwemicro.health.zm	2026-09-11 09:00:00+02	rachel.banda@kitwemicro.health.zm
46	Bacteriology Survey Two 2026 - Ndola Teaching Hospital Microbiology - Ndola Teaching Hospital Microbiology - Manual	\N	4	14	5	10	11	266	4	5	1	2026-09-18 11:43:51.727148+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.654693+02	mwila.chibesa@ndolamicro.health.zm	2026-09-18 11:43:51.893007+02	mwila.chibesa@ndolamicro.health.zm	2026-09-11 09:00:00+02	mwila.chibesa@ndolamicro.health.zm
49	Bacteriology Survey Two 2026 - Lusaka Trust Hospital Laboratory - Lusaka Trust Hospital Laboratory - Automated	\N	4	16	5	11	11	268	4	5	1	2026-09-18 11:43:51.697068+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.67494+02	davies.simukonda@lth.co.zm	2026-09-18 11:43:51.809552+02	davies.simukonda@lth.co.zm	2026-09-11 09:00:00+02	davies.simukonda@lth.co.zm
48	Bacteriology Survey Two 2026 - Kitwe Teaching Hospital Microbiology - Kitwe Teaching Hospital Microbiology - Automated	\N	4	15	5	11	11	267	4	5	1	2026-09-18 11:43:51.708096+02	wanangwa@gmail.com	Enrolment accepted	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.666848+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:51.835641+02	rachel.banda@kitwemicro.health.zm	2026-09-11 09:00:00+02	rachel.banda@kitwemicro.health.zm
54	DTS Round One 2027 - UTH New Lab - UTH New Lab - Ultra	\N	1	4	2	1	3	258	4	5	1	2026-09-24 14:28:45.252107+02	nkoleevans@gmail.com		\N	\N	\N	\N	\N	\N	2026-09-24 14:26:29.999048+02	alanphiri@gmail.com	2026-09-24 14:28:45.263445+02	nkoleevans@gmail.com	\N	\N
55	DTS Round One 2027 - UTH New Lab - UTH New Lab - XDR	\N	1	4	2	2	3	258	4	5	1	2026-09-24 14:29:07.631609+02	nkoleevans@gmail.com		\N	\N	\N	\N	\N	\N	2026-09-24 14:26:30.053297+02	alanphiri@gmail.com	2026-09-24 14:31:21.390474+02	alanphiri@gmail.com	2026-09-24 14:31:21.378864+02	alanphiri@gmail.com
\.


--
-- Data for Name: hiv_eid_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hiv_eid_results (id, name, description, scheme_id, lab_id, service_id, enrollment_id, pt_cycle_id, method_id, method_sample_id, date_panel_received, date_tested, detection_assay, extraction_assay, assay_serial_number, result_reported, hiv_result, hiv_ct_od_value, ic_qs_value, not_tested_reason, tested_by, supervisor_name, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
6	Kit Negative Control - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample Kit Negative Control for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	38	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Not Detected	\N	30	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.161387+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.916305+02	wanangwa@gmail.com	2026-09-18 11:43:49.162387+02	quality@cdl.moh.gov.zm
7	Kit Positive Control - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample Kit Positive Control for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	39	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	23.2	29.4	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.179498+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.917305+02	wanangwa@gmail.com	2026-09-18 11:43:49.180506+02	quality@cdl.moh.gov.zm
1	2026-01 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample 2026-01 for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	40	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	25.2	30.9	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.194145+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.908306+02	wanangwa@gmail.com	2026-09-18 11:43:49.195145+02	quality@cdl.moh.gov.zm
3	2026-03 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample 2026-03 for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	42	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	23.6	29.7	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.243012+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.912305+02	wanangwa@gmail.com	2026-09-18 11:43:49.243012+02	quality@cdl.moh.gov.zm
5	2026-05 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample 2026-05 for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	44	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	24.8	30.6	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.28351+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.915305+02	wanangwa@gmail.com	2026-09-18 11:43:49.284512+02	quality@cdl.moh.gov.zm
28	Kit Positive Control - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample Kit Positive Control for Kabwe General Hospital Lab	3	11	4	35	7	8	32	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Detected	24	30	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.313991+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.9445+02	wanangwa@gmail.com	2026-09-18 11:43:49.313991+02	quality@cdl.moh.gov.zm
23	2026-02 - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-02 for Kabwe General Hospital Lab	3	11	4	35	7	8	34	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	30.9	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.34553+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.940494+02	wanangwa@gmail.com	2026-09-18 11:43:49.34553+02	quality@cdl.moh.gov.zm
25	2026-04 - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-04 for Kabwe General Hospital Lab	3	11	4	35	7	8	36	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	29.7	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.37652+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.9425+02	wanangwa@gmail.com	2026-09-18 11:43:49.37652+02	quality@cdl.moh.gov.zm
26	2026-05 - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-05 for Kabwe General Hospital Lab	3	11	4	35	7	8	37	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Detected	22.8	29.1	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.399128+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.9435+02	wanangwa@gmail.com	2026-09-18 11:43:49.399128+02	quality@cdl.moh.gov.zm
21	Kit Positive Control - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample Kit Positive Control for Mansa General Hospital Lab	3	12	4	36	7	8	32	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Detected	25.2	30.9	\N	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.436936+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.938817+02	wanangwa@gmail.com	2026-09-18 11:43:49.437935+02	quality@cdl.moh.gov.zm
16	2026-02 - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-02 for Mansa General Hospital Lab	3	12	4	36	7	8	34	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Not Detected	\N	29.7	\N	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.483885+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.934813+02	wanangwa@gmail.com	2026-09-18 11:43:49.483885+02	quality@cdl.moh.gov.zm
18	2026-04 - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-04 for Mansa General Hospital Lab	3	12	4	36	7	8	36	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Not Detected	\N	30.6	\N	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.519356+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.935818+02	wanangwa@gmail.com	2026-09-18 11:43:49.519356+02	quality@cdl.moh.gov.zm
13	Kit Negative Control - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample Kit Negative Control for Mongu Provincial Hospital Lab	3	13	4	37	7	9	38	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	30.3	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.553522+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.932792+02	wanangwa@gmail.com	2026-09-18 11:43:49.553522+02	quality@cdl.moh.gov.zm
8	2026-01 - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-01 for Mongu Provincial Hospital Lab	3	13	4	37	7	9	40	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Detected	22.8	29.1	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.595434+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.924779+02	wanangwa@gmail.com	2026-09-18 11:43:49.595434+02	quality@cdl.moh.gov.zm
10	2026-03 - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-03 for Mongu Provincial Hospital Lab	3	13	4	37	7	9	42	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	30	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.633125+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.931284+02	wanangwa@gmail.com	2026-09-18 11:43:49.633125+02	quality@cdl.moh.gov.zm
12	2026-05 - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-05 for Mongu Provincial Hospital Lab	3	13	4	37	7	9	44	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Detected	25.2	30.9	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.673159+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.932288+02	wanangwa@gmail.com	2026-09-18 11:43:49.673159+02	quality@cdl.moh.gov.zm
2	2026-02 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample 2026-02 for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	41	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Not Detected	\N	30.3	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.217386+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.911305+02	wanangwa@gmail.com	2026-09-18 11:43:49.217386+02	quality@cdl.moh.gov.zm
4	2026-04 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round One 2026 panel sample 2026-04 for Levy Mwanawasa University Teaching Hospital	3	1	4	34	7	9	43	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Not Detected	\N	29.1	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:49.265046+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.913305+02	wanangwa@gmail.com	2026-09-18 11:43:49.265566+02	quality@cdl.moh.gov.zm
27	Kit Negative Control - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample Kit Negative Control for Kabwe General Hospital Lab	3	11	4	35	7	8	31	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	30.6	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.299526+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.9435+02	wanangwa@gmail.com	2026-09-18 11:43:49.300534+02	quality@cdl.moh.gov.zm
22	2026-01 - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-01 for Kabwe General Hospital Lab	3	11	4	35	7	8	33	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Detected	23.2	29.4	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.327506+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.938817+02	wanangwa@gmail.com	2026-09-18 11:43:49.327506+02	quality@cdl.moh.gov.zm
24	2026-03 - Kabwe General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-03 for Kabwe General Hospital Lab	3	11	4	35	7	8	35	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	30.3	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:49.360642+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.941499+02	wanangwa@gmail.com	2026-09-18 11:43:49.360642+02	quality@cdl.moh.gov.zm
20	Kit Negative Control - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample Kit Negative Control for Mansa General Hospital Lab	3	12	4	36	7	8	31	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Not Detected	\N	29.4	\N	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.419186+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.937818+02	wanangwa@gmail.com	2026-09-18 11:43:49.419186+02	quality@cdl.moh.gov.zm
15	2026-01 - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-01 for Mansa General Hospital Lab	3	12	4	36	7	8	33	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Detected	24.4	30.3	\N	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.461314+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.934813+02	wanangwa@gmail.com	2026-09-18 11:43:49.461314+02	quality@cdl.moh.gov.zm
17	2026-03 - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-03 for Mansa General Hospital Lab	3	12	4	36	7	8	35	2026-06-16	\N	\N	\N	\N	No	\N	\N	\N	Insufficient sample volume received	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.50168+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.935818+02	wanangwa@gmail.com	2026-09-18 11:43:49.50168+02	quality@cdl.moh.gov.zm
19	2026-05 - Mansa General Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-05 for Mansa General Hospital Lab	3	12	4	36	7	8	37	2026-06-16	2026-06-20	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Detected	24	30	\N	Mansa Technologist	Laboratory In-charge	264	4	5	1	2026-09-18 11:43:49.532972+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.936817+02	wanangwa@gmail.com	2026-09-18 11:43:49.532972+02	quality@cdl.moh.gov.zm
14	Kit Positive Control - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample Kit Positive Control for Mongu Provincial Hospital Lab	3	13	4	37	7	9	39	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Detected	23.6	29.7	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.577666+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.933303+02	wanangwa@gmail.com	2026-09-18 11:43:49.577666+02	quality@cdl.moh.gov.zm
9	2026-02 - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-02 for Mongu Provincial Hospital Lab	3	13	4	37	7	9	41	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	30.6	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.613541+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.92978+02	wanangwa@gmail.com	2026-09-18 11:43:49.613541+02	quality@cdl.moh.gov.zm
11	2026-04 - Mongu Provincial Hospital Lab	HIV-1 EID Round One 2026 panel sample 2026-04 for Mongu Provincial Hospital Lab	3	13	4	37	7	9	43	2026-06-16	2026-06-20	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	29.4	\N	Mongu Technologist	Laboratory In-charge	265	4	5	1	2026-09-18 11:43:49.650156+02	quality@cdl.moh.gov.zm	Checked against the target result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.931284+02	wanangwa@gmail.com	2026-09-18 11:43:49.651153+02	quality@cdl.moh.gov.zm
36	2026-01 - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-01 for Mansa General Hospital Lab	3	12	4	40	8	8	33	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Detected	24.4	30.3	\N	Mansa Technologist	Laboratory In-charge	264	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.036404+02	wanangwa@gmail.com	2026-09-18 11:43:50.381806+02	chola.mumba@mansa.health.zm
34	Kit Negative Control - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample Kit Negative Control for Mongu Provincial Hospital Lab	3	13	4	41	8	9	38	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	30.3	\N	Mongu Technologist	Laboratory In-charge	265	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.032892+02	wanangwa@gmail.com	2026-09-18 11:43:50.436889+02	situmbeko.imwiko@mongu.health.zm
29	2026-01 - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-01 for Mongu Provincial Hospital Lab	3	13	4	41	8	9	40	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Detected	22.8	29.1	\N	Mongu Technologist	Laboratory In-charge	265	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.026488+02	wanangwa@gmail.com	2026-09-18 11:43:50.4594+02	situmbeko.imwiko@mongu.health.zm
30	2026-02 - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-02 for Mongu Provincial Hospital Lab	3	13	4	41	8	9	41	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	30.6	\N	Mongu Technologist	Laboratory In-charge	265	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.0284+02	wanangwa@gmail.com	2026-09-18 11:43:50.481043+02	situmbeko.imwiko@mongu.health.zm
32	2026-04 - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-04 for Mongu Provincial Hospital Lab	3	13	4	41	8	9	43	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	29.4	\N	Mongu Technologist	Laboratory In-charge	265	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.031408+02	wanangwa@gmail.com	2026-09-18 11:43:50.509658+02	situmbeko.imwiko@mongu.health.zm
55	Kit Negative Control - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample Kit Negative Control for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	38	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Not Detected	\N	30	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.045424+02	wanangwa@gmail.com	2026-09-18 11:43:50.206095+02	musachoolwe@gmail.com
56	Kit Positive Control - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample Kit Positive Control for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	39	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	23.2	29.4	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.046418+02	wanangwa@gmail.com	2026-09-18 11:43:50.214614+02	musachoolwe@gmail.com
50	2026-01 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample 2026-01 for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	40	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	25.2	30.9	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.043423+02	wanangwa@gmail.com	2026-09-18 11:43:50.229708+02	musachoolwe@gmail.com
51	2026-02 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample 2026-02 for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	41	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Not Detected	\N	30.3	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.043423+02	wanangwa@gmail.com	2026-09-18 11:43:50.241292+02	musachoolwe@gmail.com
52	2026-03 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample 2026-03 for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	42	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	23.6	29.7	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.044417+02	wanangwa@gmail.com	2026-09-18 11:43:50.250299+02	musachoolwe@gmail.com
53	2026-04 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample 2026-04 for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	43	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Not Detected	\N	29.1	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.044417+02	wanangwa@gmail.com	2026-09-18 11:43:50.261812+02	musachoolwe@gmail.com
54	2026-05 - Levy Mwanawasa University Teaching Hospital	HIV-1 EID Round Two 2026 panel sample 2026-05 for Levy Mwanawasa University Teaching Hospital	3	1	4	38	8	9	44	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4001	Yes	HIV-1 Detected	24.8	30.6	\N	Levy Technologist	Laboratory In-charge	255	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.045424+02	wanangwa@gmail.com	2026-09-18 11:43:50.278408+02	musachoolwe@gmail.com
48	Kit Negative Control - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample Kit Negative Control for Kabwe General Hospital Lab	3	11	4	39	8	8	31	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	30.6	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.041418+02	wanangwa@gmail.com	2026-09-18 11:43:50.29093+02	idah.nsofwa@kabwe.health.zm
49	Kit Positive Control - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample Kit Positive Control for Kabwe General Hospital Lab	3	11	4	39	8	8	32	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Detected	24	30	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.041418+02	wanangwa@gmail.com	2026-09-18 11:43:50.301801+02	idah.nsofwa@kabwe.health.zm
43	2026-01 - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-01 for Kabwe General Hospital Lab	3	11	4	39	8	8	33	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Detected	23.2	29.4	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.039424+02	wanangwa@gmail.com	2026-09-18 11:43:50.313805+02	idah.nsofwa@kabwe.health.zm
44	2026-02 - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-02 for Kabwe General Hospital Lab	3	11	4	39	8	8	34	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	30.9	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.039424+02	wanangwa@gmail.com	2026-09-18 11:43:50.323806+02	idah.nsofwa@kabwe.health.zm
45	2026-03 - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-03 for Kabwe General Hospital Lab	3	11	4	39	8	8	35	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	30.3	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.040417+02	wanangwa@gmail.com	2026-09-18 11:43:50.334866+02	idah.nsofwa@kabwe.health.zm
46	2026-04 - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-04 for Kabwe General Hospital Lab	3	11	4	39	8	8	36	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Not Detected	\N	29.7	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.040417+02	wanangwa@gmail.com	2026-09-18 11:43:50.345713+02	idah.nsofwa@kabwe.health.zm
47	2026-05 - Kabwe General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-05 for Kabwe General Hospital Lab	3	11	4	39	8	8	37	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4011	Yes	HIV-1 Detected	22.8	29.1	\N	Kabwe Technologist	Laboratory In-charge	263	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.041418+02	wanangwa@gmail.com	2026-09-18 11:43:50.353712+02	idah.nsofwa@kabwe.health.zm
41	Kit Negative Control - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample Kit Negative Control for Mansa General Hospital Lab	3	12	4	40	8	8	31	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Not Detected	\N	29.4	\N	Mansa Technologist	Laboratory In-charge	264	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.038418+02	wanangwa@gmail.com	2026-09-18 11:43:50.36226+02	chola.mumba@mansa.health.zm
42	Kit Positive Control - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample Kit Positive Control for Mansa General Hospital Lab	3	12	4	40	8	8	32	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Detected	25.2	30.9	\N	Mansa Technologist	Laboratory In-charge	264	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.039424+02	wanangwa@gmail.com	2026-09-18 11:43:50.370291+02	chola.mumba@mansa.health.zm
37	2026-02 - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-02 for Mansa General Hospital Lab	3	12	4	40	8	8	34	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Not Detected	\N	29.7	\N	Mansa Technologist	Laboratory In-charge	264	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.036404+02	wanangwa@gmail.com	2026-09-18 11:43:50.392843+02	chola.mumba@mansa.health.zm
38	2026-03 - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-03 for Mansa General Hospital Lab	3	12	4	40	8	8	35	2026-09-12	\N	\N	\N	\N	No	\N	\N	\N	Insufficient sample volume received	Mansa Technologist	Laboratory In-charge	264	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.036404+02	wanangwa@gmail.com	2026-09-18 11:43:50.401121+02	chola.mumba@mansa.health.zm
39	2026-04 - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-04 for Mansa General Hospital Lab	3	12	4	40	8	8	36	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Not Detected	\N	30.6	\N	Mansa Technologist	Laboratory In-charge	264	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.037412+02	wanangwa@gmail.com	2026-09-18 11:43:50.412631+02	chola.mumba@mansa.health.zm
40	2026-05 - Mansa General Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-05 for Mansa General Hospital Lab	3	12	4	40	8	8	37	2026-09-12	2026-09-13	Cobas 4800	Cobas 4800	SN-4012	Yes	HIV-1 Detected	24	30	\N	Mansa Technologist	Laboratory In-charge	264	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.037412+02	wanangwa@gmail.com	2026-09-18 11:43:50.42624+02	chola.mumba@mansa.health.zm
35	Kit Positive Control - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample Kit Positive Control for Mongu Provincial Hospital Lab	3	13	4	41	8	9	39	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Detected	23.6	29.7	\N	Mongu Technologist	Laboratory In-charge	265	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.032892+02	wanangwa@gmail.com	2026-09-18 11:43:50.4484+02	situmbeko.imwiko@mongu.health.zm
31	2026-03 - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-03 for Mongu Provincial Hospital Lab	3	13	4	41	8	9	42	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Not Detected	\N	30	\N	Mongu Technologist	Laboratory In-charge	265	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.030412+02	wanangwa@gmail.com	2026-09-18 11:43:50.494087+02	situmbeko.imwiko@mongu.health.zm
33	2026-05 - Mongu Provincial Hospital Lab	HIV-1 EID Round Two 2026 panel sample 2026-05 for Mongu Provincial Hospital Lab	3	13	4	41	8	9	44	2026-09-12	2026-09-13	GeneXpert	GeneXpert	SN-4013	Yes	HIV-1 Detected	25.2	30.9	\N	Mongu Technologist	Laboratory In-charge	265	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.031408+02	wanangwa@gmail.com	2026-09-18 11:43:50.519667+02	situmbeko.imwiko@mongu.health.zm
\.


--
-- Data for Name: hiv_vl_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hiv_vl_results (id, name, description, scheme_id, lab_id, service_id, enrollment_id, pt_cycle_id, method_id, method_sample_id, date_panel_received, date_tested, detection_assay, extraction_assay, assay_kit_lot_number, assay_kit_expiry_date, assay_serial_number, result_reported, viral_load_log10, not_tested_reason, tested_by, supervisor_name, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
17	VL 2026-A2 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round One 2026 panel sample VL 2026-A2 for Levy Mwanawasa University Teaching Hospital	2	1	3	24	5	7	27	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	2.52	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:47.526702+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.141616+02	wanangwa@gmail.com	2026-09-18 11:43:47.527707+02	quality@cdl.moh.gov.zm
16	VL 2026-A1 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round One 2026 panel sample VL 2026-A1 for Levy Mwanawasa University Teaching Hospital	2	1	3	24	5	7	26	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	0	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:47.496982+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.14062+02	wanangwa@gmail.com	2026-09-18 11:43:47.498484+02	quality@cdl.moh.gov.zm
18	VL 2026-A3 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round One 2026 panel sample VL 2026-A3 for Levy Mwanawasa University Teaching Hospital	2	1	3	24	5	7	28	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	5.58	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:47.544427+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.141616+02	wanangwa@gmail.com	2026-09-18 11:43:47.544427+02	quality@cdl.moh.gov.zm
19	VL 2026-A4 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round One 2026 panel sample VL 2026-A4 for Levy Mwanawasa University Teaching Hospital	2	1	3	24	5	7	29	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	5.29	\N	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:47.560449+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.142617+02	wanangwa@gmail.com	2026-09-18 11:43:47.561476+02	quality@cdl.moh.gov.zm
20	VL 2026-A5 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round One 2026 panel sample VL 2026-A5 for Levy Mwanawasa University Teaching Hospital	2	1	3	24	5	7	30	2026-06-06	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Levy Technologist	Laboratory In-charge	255	4	5	1	2026-09-18 11:43:47.577028+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.142617+02	wanangwa@gmail.com	2026-09-18 11:43:47.578533+02	quality@cdl.moh.gov.zm
11	VL 2026-A1 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A1 for Arthur Davison Childrens Hospital Lab	2	9	3	25	5	5	16	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	0	\N	Arthur Technologist	Laboratory In-charge	261	4	5	1	2026-09-18 11:43:47.593602+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.138617+02	wanangwa@gmail.com	2026-09-18 11:43:47.593602+02	quality@cdl.moh.gov.zm
13	VL 2026-A3 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A3 for Arthur Davison Childrens Hospital Lab	2	9	3	25	5	5	18	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	3.86	\N	Arthur Technologist	Laboratory In-charge	261	4	5	1	2026-09-18 11:43:47.625632+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.139617+02	wanangwa@gmail.com	2026-09-18 11:43:47.625632+02	quality@cdl.moh.gov.zm
15	VL 2026-A5 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A5 for Arthur Davison Childrens Hospital Lab	2	9	3	25	5	5	20	2026-06-06	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Arthur Technologist	Laboratory In-charge	261	4	5	1	2026-09-18 11:43:47.655296+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.14062+02	wanangwa@gmail.com	2026-09-18 11:43:47.655296+02	quality@cdl.moh.gov.zm
7	VL 2026-A2 - Chipata Central Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A2 for Chipata Central Hospital Lab	2	10	3	26	5	6	22	2026-06-06	2026-06-11	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	2.44	\N	Chipata Technologist	Laboratory In-charge	262	4	5	1	2026-09-18 11:43:47.686312+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.136104+02	wanangwa@gmail.com	2026-09-18 11:43:47.686312+02	quality@cdl.moh.gov.zm
9	VL 2026-A4 - Chipata Central Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A4 for Chipata Central Hospital Lab	2	10	3	26	5	6	24	2026-06-06	2026-06-11	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	5.21	\N	Chipata Technologist	Laboratory In-charge	262	4	5	1	2026-09-18 11:43:47.715872+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.137104+02	wanangwa@gmail.com	2026-09-18 11:43:47.715872+02	quality@cdl.moh.gov.zm
1	VL 2026-A1 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A1 for Kabwe General Hospital Lab	2	11	3	27	5	5	16	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	0	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.751135+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.126008+02	wanangwa@gmail.com	2026-09-18 11:43:47.751135+02	quality@cdl.moh.gov.zm
3	VL 2026-A3 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A3 for Kabwe General Hospital Lab	2	11	3	27	5	5	18	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	5.18	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.785692+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.130006+02	wanangwa@gmail.com	2026-09-18 11:43:47.786909+02	quality@cdl.moh.gov.zm
5	VL 2026-A5 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A5 for Kabwe General Hospital Lab	2	11	3	27	5	5	20	2026-06-06	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.823448+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.132106+02	wanangwa@gmail.com	2026-09-18 11:43:47.824443+02	quality@cdl.moh.gov.zm
22	VL 2026-A2 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A2 for Kabwe General Hospital Lab	2	11	3	28	5	7	27	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	2.44	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.882481+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.143621+02	wanangwa@gmail.com	2026-09-18 11:43:47.882481+02	quality@cdl.moh.gov.zm
24	VL 2026-A4 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A4 for Kabwe General Hospital Lab	2	11	3	28	5	7	29	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	5.21	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.953018+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.144616+02	wanangwa@gmail.com	2026-09-18 11:43:47.953018+02	quality@cdl.moh.gov.zm
40	VL 2026-A5 - Chipata Central Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A5 for Chipata Central Hospital Lab	2	10	3	31	6	6	25	2026-09-12	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Chipata Technologist	Laboratory In-charge	262	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.25271+02	wanangwa@gmail.com	2026-09-18 11:43:48.602358+02	foster.tembo@chipata.health.zm
12	VL 2026-A2 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A2 for Arthur Davison Childrens Hospital Lab	2	9	3	25	5	5	17	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	2.76	\N	Arthur Technologist	Laboratory In-charge	261	4	5	1	2026-09-18 11:43:47.609418+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.138617+02	wanangwa@gmail.com	2026-09-18 11:43:47.609418+02	quality@cdl.moh.gov.zm
14	VL 2026-A4 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A4 for Arthur Davison Childrens Hospital Lab	2	9	3	25	5	5	19	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	4.97	\N	Arthur Technologist	Laboratory In-charge	261	4	5	1	2026-09-18 11:43:47.640087+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.139617+02	wanangwa@gmail.com	2026-09-18 11:43:47.641089+02	quality@cdl.moh.gov.zm
6	VL 2026-A1 - Chipata Central Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A1 for Chipata Central Hospital Lab	2	10	3	26	5	6	21	2026-06-06	2026-06-11	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	0	\N	Chipata Technologist	Laboratory In-charge	262	4	5	1	2026-09-18 11:43:47.668877+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.135103+02	wanangwa@gmail.com	2026-09-18 11:43:47.669861+02	quality@cdl.moh.gov.zm
8	VL 2026-A3 - Chipata Central Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A3 for Chipata Central Hospital Lab	2	10	3	26	5	6	23	2026-06-06	2026-06-11	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	4.1	\N	Chipata Technologist	Laboratory In-charge	262	4	5	1	2026-09-18 11:43:47.699825+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.136104+02	wanangwa@gmail.com	2026-09-18 11:43:47.700829+02	quality@cdl.moh.gov.zm
10	VL 2026-A5 - Chipata Central Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A5 for Chipata Central Hospital Lab	2	10	3	26	5	6	25	2026-06-06	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Chipata Technologist	Laboratory In-charge	262	4	5	1	2026-09-18 11:43:47.734423+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.137613+02	wanangwa@gmail.com	2026-09-18 11:43:47.734423+02	quality@cdl.moh.gov.zm
2	VL 2026-A2 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A2 for Kabwe General Hospital Lab	2	11	3	27	5	5	17	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	2.68	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.768184+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.129005+02	wanangwa@gmail.com	2026-09-18 11:43:47.768184+02	quality@cdl.moh.gov.zm
4	VL 2026-A4 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A4 for Kabwe General Hospital Lab	2	11	3	27	5	5	19	2026-06-06	2026-06-11	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	5.45	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.801923+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.131103+02	wanangwa@gmail.com	2026-09-18 11:43:47.802918+02	quality@cdl.moh.gov.zm
21	VL 2026-A1 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A1 for Kabwe General Hospital Lab	2	11	3	28	5	7	26	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	0	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.856453+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.143621+02	wanangwa@gmail.com	2026-09-18 11:43:47.857454+02	quality@cdl.moh.gov.zm
23	VL 2026-A3 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A3 for Kabwe General Hospital Lab	2	11	3	28	5	7	28	2026-06-06	2026-06-11	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	4.1	\N	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.915485+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.144616+02	wanangwa@gmail.com	2026-09-18 11:43:47.915485+02	quality@cdl.moh.gov.zm
25	VL 2026-A5 - Kabwe General Hospital Lab	HIV-1 VL Round One 2026 panel sample VL 2026-A5 for Kabwe General Hospital Lab	2	11	3	28	5	7	30	2026-06-06	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Kabwe Technologist	Laboratory In-charge	263	4	5	1	2026-09-18 11:43:47.991485+02	quality@cdl.moh.gov.zm	Within the assigned value +/- the allowable range	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:47.144616+02	wanangwa@gmail.com	2026-09-18 11:43:47.992485+02	quality@cdl.moh.gov.zm
38	VL 2026-A3 - Chipata Central Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A3 for Chipata Central Hospital Lab	2	10	3	31	6	6	23	2026-09-12	2026-09-13	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	4.1	\N	Chipata Technologist	Laboratory In-charge	262	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.251711+02	wanangwa@gmail.com	2026-09-18 11:43:48.582758+02	foster.tembo@chipata.health.zm
31	VL 2026-A1 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A1 for Kabwe General Hospital Lab	2	11	3	32	6	5	16	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	0	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.244709+02	wanangwa@gmail.com	2026-09-18 11:43:48.610359+02	idah.nsofwa@kabwe.health.zm
32	VL 2026-A2 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A2 for Kabwe General Hospital Lab	2	11	3	32	6	5	17	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	2.68	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.245709+02	wanangwa@gmail.com	2026-09-18 11:43:48.617367+02	idah.nsofwa@kabwe.health.zm
34	VL 2026-A4 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A4 for Kabwe General Hospital Lab	2	11	3	32	6	5	19	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	5.45	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.24771+02	wanangwa@gmail.com	2026-09-18 11:43:48.637402+02	idah.nsofwa@kabwe.health.zm
26	VL 2026-A1 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A1 for Kabwe General Hospital Lab	2	11	3	33	6	7	26	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	0	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.239691+02	wanangwa@gmail.com	2026-09-18 11:43:48.66951+02	idah.nsofwa@kabwe.health.zm
27	VL 2026-A2 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A2 for Kabwe General Hospital Lab	2	11	3	33	6	7	27	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	2.44	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.240702+02	wanangwa@gmail.com	2026-09-18 11:43:48.681034+02	idah.nsofwa@kabwe.health.zm
29	VL 2026-A4 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A4 for Kabwe General Hospital Lab	2	11	3	33	6	7	29	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	5.21	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.243709+02	wanangwa@gmail.com	2026-09-18 11:43:48.703325+02	idah.nsofwa@kabwe.health.zm
46	VL 2026-A1 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round Two 2026 panel sample VL 2026-A1 for Levy Mwanawasa University Teaching Hospital	2	1	3	29	6	7	26	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	0	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.255709+02	wanangwa@gmail.com	2026-09-18 11:43:48.448853+02	musachoolwe@gmail.com
47	VL 2026-A2 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round Two 2026 panel sample VL 2026-A2 for Levy Mwanawasa University Teaching Hospital	2	1	3	29	6	7	27	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	2.52	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.256708+02	wanangwa@gmail.com	2026-09-18 11:43:48.457873+02	musachoolwe@gmail.com
48	VL 2026-A3 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round Two 2026 panel sample VL 2026-A3 for Levy Mwanawasa University Teaching Hospital	2	1	3	29	6	7	28	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	5.58	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.256708+02	wanangwa@gmail.com	2026-09-18 11:43:48.47339+02	musachoolwe@gmail.com
49	VL 2026-A4 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round Two 2026 panel sample VL 2026-A4 for Levy Mwanawasa University Teaching Hospital	2	1	3	29	6	7	29	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2601	2027-06-30	SN-9001	Yes	5.29	\N	Levy Technologist	Laboratory In-charge	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.256708+02	wanangwa@gmail.com	2026-09-18 11:43:48.486448+02	musachoolwe@gmail.com
50	VL 2026-A5 - Levy Mwanawasa University Teaching Hospital	HIV-1 VL Round Two 2026 panel sample VL 2026-A5 for Levy Mwanawasa University Teaching Hospital	2	1	3	29	6	7	30	2026-09-12	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Levy Technologist	Laboratory In-charge	255	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.256708+02	wanangwa@gmail.com	2026-09-18 11:43:48.49945+02	musachoolwe@gmail.com
41	VL 2026-A1 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A1 for Arthur Davison Childrens Hospital Lab	2	9	3	30	6	5	16	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	0	\N	Arthur Technologist	Laboratory In-charge	261	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.25271+02	wanangwa@gmail.com	2026-09-18 11:43:48.513505+02	chanda.mwape@adch.health.zm
42	VL 2026-A2 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A2 for Arthur Davison Childrens Hospital Lab	2	9	3	30	6	5	17	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	2.76	\N	Arthur Technologist	Laboratory In-charge	261	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.253709+02	wanangwa@gmail.com	2026-09-18 11:43:48.524503+02	chanda.mwape@adch.health.zm
43	VL 2026-A3 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A3 for Arthur Davison Childrens Hospital Lab	2	9	3	30	6	5	18	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	3.86	\N	Arthur Technologist	Laboratory In-charge	261	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.253709+02	wanangwa@gmail.com	2026-09-18 11:43:48.53454+02	chanda.mwape@adch.health.zm
44	VL 2026-A4 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A4 for Arthur Davison Childrens Hospital Lab	2	9	3	30	6	5	19	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2609	2027-06-30	SN-9009	Yes	4.97	\N	Arthur Technologist	Laboratory In-charge	261	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.253709+02	wanangwa@gmail.com	2026-09-18 11:43:48.545549+02	chanda.mwape@adch.health.zm
45	VL 2026-A5 - Arthur Davison Childrens Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A5 for Arthur Davison Childrens Hospital Lab	2	9	3	30	6	5	20	2026-09-12	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Arthur Technologist	Laboratory In-charge	261	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.255709+02	wanangwa@gmail.com	2026-09-18 11:43:48.556558+02	chanda.mwape@adch.health.zm
36	VL 2026-A1 - Chipata Central Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A1 for Chipata Central Hospital Lab	2	10	3	31	6	6	21	2026-09-12	2026-09-13	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	0	\N	Chipata Technologist	Laboratory In-charge	262	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.249713+02	wanangwa@gmail.com	2026-09-18 11:43:48.564565+02	foster.tembo@chipata.health.zm
37	VL 2026-A2 - Chipata Central Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A2 for Chipata Central Hospital Lab	2	10	3	31	6	6	22	2026-09-12	2026-09-13	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	2.44	\N	Chipata Technologist	Laboratory In-charge	262	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.249713+02	wanangwa@gmail.com	2026-09-18 11:43:48.573082+02	foster.tembo@chipata.health.zm
39	VL 2026-A4 - Chipata Central Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A4 for Chipata Central Hospital Lab	2	10	3	31	6	6	24	2026-09-12	2026-09-13	Roche Cobas 6800	Roche Cobas 6800	LOT-2610	2027-06-30	SN-9010	Yes	5.21	\N	Chipata Technologist	Laboratory In-charge	262	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.251711+02	wanangwa@gmail.com	2026-09-18 11:43:48.592793+02	foster.tembo@chipata.health.zm
33	VL 2026-A3 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A3 for Kabwe General Hospital Lab	2	11	3	32	6	5	18	2026-09-12	2026-09-13	Abbott m2000	Abbott m2000	LOT-2611	2027-06-30	SN-9011	Yes	5.18	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.245709+02	wanangwa@gmail.com	2026-09-18 11:43:48.628366+02	idah.nsofwa@kabwe.health.zm
35	VL 2026-A5 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A5 for Kabwe General Hospital Lab	2	11	3	32	6	5	20	2026-09-12	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.248711+02	wanangwa@gmail.com	2026-09-18 11:43:48.655937+02	idah.nsofwa@kabwe.health.zm
28	VL 2026-A3 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A3 for Kabwe General Hospital Lab	2	11	3	33	6	7	28	2026-09-12	2026-09-13	Hologic Panther	Hologic Panther	LOT-2611	2027-06-30	SN-9011	Yes	4.1	\N	Kabwe Technologist	Laboratory In-charge	263	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.2427+02	wanangwa@gmail.com	2026-09-18 11:43:48.691765+02	idah.nsofwa@kabwe.health.zm
30	VL 2026-A5 - Kabwe General Hospital Lab	HIV-1 VL Round Two 2026 panel sample VL 2026-A5 for Kabwe General Hospital Lab	2	11	3	33	6	7	30	2026-09-12	\N	\N	\N	\N	\N	\N	No	\N	Panel arrived thawed, sample integrity compromised	Kabwe Technologist	Laboratory In-charge	263	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.244709+02	wanangwa@gmail.com	2026-09-18 11:43:48.714324+02	idah.nsofwa@kabwe.health.zm
\.


--
-- Data for Name: lab_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lab_types (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Government	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:19:22.13977+02	\N	\N	\N
2	Private	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:19:22.15481+02	\N	\N	\N
3	Religious	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:19:22.159843+02	\N	\N	\N
4	Mine	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:50:34.687177+02	\N	2026-09-14 20:23:25.62316+02	\N
\.


--
-- Data for Name: laboratorys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.laboratorys (id, name, description, contact_person_name, code, lab_type_id, "position", district_id, province_id, phone_number, physical_address, email_address, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, method_list) FROM stdin;
8	Solwezi Mine Clinic Lab	\N	Brian Kunda	REG0008	4	Laboratory In-charge	103	8	+260976516428	Solwezi Mine Clinic Lab, Zambia	brian.kunda@solwezi.health.zm	\N	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.804046+02	brian.kunda@solwezi.health.zm	\N	\N	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}]
3	Private Lab 1	\N	Mark Doe	REG0003	2	Laboratory In-charge	10	2	+260975817667	Private Lab 1, Zambia	markdoe@gmail.com	257	4	5	1	2026-09-18 11:43:42.242142+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.772405+02	markdoe@gmail.com	2026-09-18 11:43:42.314877+02	wanangwa@gmail.com	[{"id": 3, "name": "Ziehl-Neelsen", "scheme_id": 1, "service_id": 1}, {"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}]
2	Levy Lusaka Laboratory	\N	Jane Banda	REG0002	1	Laboratory In-charge	39	5	+260970703338	Levy Lusaka Laboratory, Zambia	jane@gmail.com	256	4	5	1	2026-09-18 11:43:42.093949+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.764372+02	jane@gmail.com	2026-09-18 11:43:42.161853+02	wanangwa@gmail.com	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}]
4	UTH New Lab	\N	Alan Phiri	REG0004	1	Laboratory In-charge	39	5	+260977960898	UTH New Lab, Zambia	alanphiri@gmail.com	258	4	5	1	2026-09-18 11:43:42.388181+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.779925+02	alanphiri@gmail.com	2026-09-18 11:43:42.446522+02	wanangwa@gmail.com	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}, {"id": 2, "name": "XDR", "scheme_id": 1, "service_id": 2}]
7	Livingstone Central Hospital Lab	\N	Naomi Sakala	REG0007	1	Laboratory In-charge	45	9	+260979809601	Livingstone Central Hospital Lab, Zambia	naomi.sakala@livingstone.health.zm	\N	5	2	1	2026-09-18 11:43:42.765241+02	wanangwa@gmail.com	Documentation incomplete - please reapply	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.798018+02	naomi.sakala@livingstone.health.zm	2026-09-18 11:43:42.766243+02	wanangwa@gmail.com	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}]
5	Ndola Teaching Hospital Lab	\N	Grace Mulenga	REG0005	1	Laboratory In-charge	10	2	+260973546432	Ndola Teaching Hospital Lab, Zambia	grace.mulenga@ndola.health.zm	259	4	5	1	2026-09-18 11:43:42.510558+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.785923+02	grace.mulenga@ndola.health.zm	2026-09-18 11:43:42.56328+02	wanangwa@gmail.com	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}]
6	Kitwe Central Hospital Lab	\N	Peter Zulu	REG0006	1	Laboratory In-charge	4	2	+260979319651	Kitwe Central Hospital Lab, Zambia	peter.zulu@kitwe.health.zm	260	4	5	1	2026-09-18 11:43:42.629627+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.792002+02	peter.zulu@kitwe.health.zm	2026-09-18 11:43:42.693287+02	wanangwa@gmail.com	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}, {"id": 2, "name": "XDR", "scheme_id": 1, "service_id": 2}]
9	Arthur Davison Childrens Hospital Lab	\N	Chanda Mwape	REG0009	1	Laboratory In-charge	10	2	+260972493914	Arthur Davison Childrens Hospital Lab, Zambia	chanda.mwape@adch.health.zm	261	4	5	1	2026-09-18 11:43:42.774499+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.809689+02	chanda.mwape@adch.health.zm	2026-09-18 11:43:42.831544+02	wanangwa@gmail.com	[{"id": 5, "name": "Abbott m2000", "scheme_id": 2, "service_id": 3}]
10	Chipata Central Hospital Lab	\N	Foster Tembo	REG0010	1	Laboratory In-charge	15	3	+260979709193	Chipata Central Hospital Lab, Zambia	foster.tembo@chipata.health.zm	262	4	5	1	2026-09-18 11:43:42.902276+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.815686+02	foster.tembo@chipata.health.zm	2026-09-18 11:43:42.961497+02	wanangwa@gmail.com	[{"id": 6, "name": "Roche Cobas 6800", "scheme_id": 2, "service_id": 3}]
12	Mansa General Hospital Lab	\N	Chola Mumba	REG0012	1	Laboratory In-charge	71	4	+260977394710	Mansa General Hospital Lab, Zambia	chola.mumba@mansa.health.zm	264	4	5	1	2026-09-18 11:43:43.144182+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.834221+02	chola.mumba@mansa.health.zm	2026-09-18 11:43:43.199098+02	wanangwa@gmail.com	[{"id": 8, "name": "Cobas 4800", "scheme_id": 3, "service_id": 4}]
13	Mongu Provincial Hospital Lab	\N	Situmbeko Imwiko	REG0013	1	Laboratory In-charge	82	10	+260971036651	Mongu Provincial Hospital Lab, Zambia	situmbeko.imwiko@mongu.health.zm	265	4	5	1	2026-09-18 11:43:43.261679+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.84009+02	situmbeko.imwiko@mongu.health.zm	2026-09-18 11:43:43.316591+02	wanangwa@gmail.com	[{"id": 9, "name": "GeneXpert HIV-1 Qual", "scheme_id": 3, "service_id": 4}]
14	Ndola Teaching Hospital Microbiology	\N	Mwila Chibesa	REG0014	1	Laboratory In-charge	10	2	+260974323277	Ndola Teaching Hospital Microbiology, Zambia	mwila.chibesa@ndolamicro.health.zm	266	4	5	1	2026-09-18 11:43:43.381467+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.845156+02	mwila.chibesa@ndolamicro.health.zm	2026-09-18 11:43:43.445071+02	wanangwa@gmail.com	[{"id": 10, "name": "Manual", "scheme_id": 4, "service_id": 5}]
15	Kitwe Teaching Hospital Microbiology	\N	Rachel Banda	REG0015	1	Laboratory In-charge	4	2	+260979541479	Kitwe Teaching Hospital Microbiology, Zambia	rachel.banda@kitwemicro.health.zm	267	4	5	1	2026-09-18 11:43:43.515553+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.849158+02	rachel.banda@kitwemicro.health.zm	2026-09-18 11:43:43.577931+02	wanangwa@gmail.com	[{"id": 10, "name": "Manual", "scheme_id": 4, "service_id": 5}, {"id": 11, "name": "Automated", "scheme_id": 4, "service_id": 5}]
16	Lusaka Trust Hospital Laboratory	\N	Davies Simukonda	REG0016	2	Laboratory In-charge	39	5	+260973116984	Lusaka Trust Hospital Laboratory, Zambia	davies.simukonda@lth.co.zm	268	4	5	1	2026-09-18 11:43:43.654886+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.856185+02	davies.simukonda@lth.co.zm	2026-09-18 11:43:43.718989+02	wanangwa@gmail.com	[{"id": 11, "name": "Automated", "scheme_id": 4, "service_id": 5}]
1	Levy Mwanawasa University Teaching Hospital	\N	Musa Choolwe	REG0001	1	Laboratory In-charge	39	5	+260979054634	Levy Mwanawasa University Teaching Hospital, Zambia	musachoolwe@gmail.com	255	4	5	1	2026-09-18 11:43:41.877255+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.741067+02	musachoolwe@gmail.com	2026-09-18 11:43:41.976072+02	wanangwa@gmail.com	[{"id": 1, "name": "Ultra", "scheme_id": 1, "service_id": 2}, {"id": 2, "name": "XDR", "scheme_id": 1, "service_id": 2}, {"id": 7, "name": "Hologic Panther", "scheme_id": 2, "service_id": 3}, {"id": 9, "name": "GeneXpert HIV-1 Qual", "scheme_id": 3, "service_id": 4}]
11	Kabwe General Hospital Lab	\N	Idah Nsofwa	REG0011	1	Laboratory In-charge	26	1	+260970856398	Kabwe General Hospital Lab, Zambia	idah.nsofwa@kabwe.health.zm	263	4	5	1	2026-09-18 11:43:43.025661+02	wanangwa@gmail.com	Registration verified against the CDL register	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.827197+02	idah.nsofwa@kabwe.health.zm	2026-09-18 11:43:43.078814+02	wanangwa@gmail.com	[{"id": 5, "name": "Abbott m2000", "scheme_id": 2, "service_id": 3}, {"id": 7, "name": "Hologic Panther", "scheme_id": 2, "service_id": 3}, {"id": 8, "name": "Cobas 4800", "scheme_id": 3, "service_id": 4}]
\.


--
-- Data for Name: list_stages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list_stages (id, stage_name, description, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Awaiting Submission	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
2	Submitted	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
3	First Approval	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
4	Second Approval	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
5	Approved	\N	2026-07-22 05:34:05.53067+02	System	\N	\N
\.


--
-- Data for Name: list_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.list_statuses (id, status_name, description, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Draft	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
2	Submitted	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
3	Under Review	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
4	Approved	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
5	Rejected	\N	2026-07-22 05:34:01.39012+02	System	\N	\N
\.


--
-- Data for Name: meters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meters (id, name, description, customer_number, customer_name, identity_number, address, communicate_address, invoice_number, open_account_date, station_name, operator_uid, province_name, city_name, town_name, village_name, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: method_sample_expected_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.method_sample_expected_values (id, method_sample_id, attribute, expected_value_numeric, expected_value_text, created_at, created_by, updated_at, updated_by) FROM stdin;
1	1	tb_detection_result	\N	NOT DETECTED	2026-09-18 11:43:41.682809+02	demo-seed	\N	\N
2	1	rif_result	\N	N/A	2026-09-18 11:43:41.685811+02	demo-seed	\N	\N
3	2	tb_detection_result	\N	HIGH	2026-09-18 11:43:41.686813+02	demo-seed	\N	\N
4	2	rif_result	\N	NOT DETECTED	2026-09-18 11:43:41.686813+02	demo-seed	\N	\N
5	3	tb_detection_result	\N	MEDIUM	2026-09-18 11:43:41.686813+02	demo-seed	\N	\N
6	3	rif_result	\N	DETECTED	2026-09-18 11:43:41.687812+02	demo-seed	\N	\N
7	4	tb_detection_result	\N	TRACE	2026-09-18 11:43:41.687812+02	demo-seed	\N	\N
8	4	rif_result	\N	N/A	2026-09-18 11:43:41.687812+02	demo-seed	\N	\N
9	5	tb_detection_result	\N	LOW	2026-09-18 11:43:41.688812+02	demo-seed	\N	\N
10	5	rif_result	\N	NOT DETECTED	2026-09-18 11:43:41.688812+02	demo-seed	\N	\N
11	6	tb_detection_result	\N	NOT DETECTED	2026-09-18 11:43:41.688812+02	demo-seed	\N	\N
12	6	inh_result	\N	N/A	2026-09-18 11:43:41.688812+02	demo-seed	\N	\N
13	6	flq_result	\N	N/A	2026-09-18 11:43:41.689811+02	demo-seed	\N	\N
14	6	amk_result	\N	N/A	2026-09-18 11:43:41.689811+02	demo-seed	\N	\N
15	6	eth_result	\N	N/A	2026-09-18 11:43:41.689811+02	demo-seed	\N	\N
16	7	tb_detection_result	\N	DETECTED	2026-09-18 11:43:41.689811+02	demo-seed	\N	\N
17	7	inh_result	\N	NOT DETECTED	2026-09-18 11:43:41.690815+02	demo-seed	\N	\N
18	7	flq_result	\N	NOT DETECTED	2026-09-18 11:43:41.690815+02	demo-seed	\N	\N
19	7	amk_result	\N	NOT DETECTED	2026-09-18 11:43:41.690815+02	demo-seed	\N	\N
20	7	eth_result	\N	NOT DETECTED	2026-09-18 11:43:41.690815+02	demo-seed	\N	\N
21	8	tb_detection_result	\N	DETECTED	2026-09-18 11:43:41.691812+02	demo-seed	\N	\N
22	8	inh_result	\N	DETECTED	2026-09-18 11:43:41.691812+02	demo-seed	\N	\N
23	8	flq_result	\N	NOT DETECTED	2026-09-18 11:43:41.691812+02	demo-seed	\N	\N
24	8	amk_result	\N	NOT DETECTED	2026-09-18 11:43:41.691812+02	demo-seed	\N	\N
25	8	eth_result	\N	DETECTED	2026-09-18 11:43:41.692813+02	demo-seed	\N	\N
26	9	tb_detection_result	\N	DETECTED	2026-09-18 11:43:41.692813+02	demo-seed	\N	\N
27	9	inh_result	\N	DETECTED	2026-09-18 11:43:41.692813+02	demo-seed	\N	\N
28	9	flq_result	\N	DETECTED	2026-09-18 11:43:41.692813+02	demo-seed	\N	\N
29	9	amk_result	\N	NOT DETECTED	2026-09-18 11:43:41.692813+02	demo-seed	\N	\N
30	9	eth_result	\N	DETECTED	2026-09-18 11:43:41.69432+02	demo-seed	\N	\N
31	10	tb_detection_result	\N	DETECTED	2026-09-18 11:43:41.69432+02	demo-seed	\N	\N
32	10	inh_result	\N	NOT DETECTED	2026-09-18 11:43:41.69432+02	demo-seed	\N	\N
33	10	flq_result	\N	NOT DETECTED	2026-09-18 11:43:41.69432+02	demo-seed	\N	\N
34	10	amk_result	\N	DETECTED	2026-09-18 11:43:41.69432+02	demo-seed	\N	\N
35	10	eth_result	\N	NOT DETECTED	2026-09-18 11:43:41.695325+02	demo-seed	\N	\N
36	31	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.695325+02	demo-seed	\N	\N
37	32	hiv_result	\N	HIV-1 Detected	2026-09-18 11:43:41.695325+02	demo-seed	\N	\N
38	33	hiv_result	\N	HIV-1 Detected	2026-09-18 11:43:41.695325+02	demo-seed	\N	\N
39	34	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.696326+02	demo-seed	\N	\N
40	35	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.696326+02	demo-seed	\N	\N
41	36	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.696326+02	demo-seed	\N	\N
42	37	hiv_result	\N	HIV-1 Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
43	38	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
44	39	hiv_result	\N	HIV-1 Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
45	40	hiv_result	\N	HIV-1 Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
46	41	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
47	42	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
48	43	hiv_result	\N	HIV-1 Not Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
49	44	hiv_result	\N	HIV-1 Detected	2026-09-18 11:43:41.697325+02	demo-seed	\N	\N
50	45	gram_stain_reaction	\N	Gram negative	2026-09-18 11:43:41.699095+02	demo-seed	\N	\N
51	45	gram_morphology	\N	Bacilli	2026-09-18 11:43:41.699095+02	demo-seed	\N	\N
52	45	organism_identified	\N	Escherichia coli	2026-09-18 11:43:41.699095+02	demo-seed	\N	\N
53	46	gram_stain_reaction	\N	Gram positive	2026-09-18 11:43:41.699095+02	demo-seed	\N	\N
54	46	gram_morphology	\N	Cocci	2026-09-18 11:43:41.700101+02	demo-seed	\N	\N
55	46	organism_identified	\N	Staphylococcus epidermidis	2026-09-18 11:43:41.700101+02	demo-seed	\N	\N
56	47	gram_stain_reaction	\N	Gram positive	2026-09-18 11:43:41.700101+02	demo-seed	\N	\N
57	47	gram_morphology	\N	Diplococci	2026-09-18 11:43:41.700101+02	demo-seed	\N	\N
58	47	organism_identified	\N	Streptococcus agalactiae	2026-09-18 11:43:41.701102+02	demo-seed	\N	\N
59	48	gram_stain_reaction	\N	Gram positive	2026-09-18 11:43:41.701102+02	demo-seed	\N	\N
60	48	gram_morphology	\N	Cocci	2026-09-18 11:43:41.701102+02	demo-seed	\N	\N
61	48	organism_identified	\N	Staphylococcus aureus	2026-09-18 11:43:41.701102+02	demo-seed	\N	\N
62	49	gram_stain_reaction	\N	Gram negative	2026-09-18 11:43:41.702101+02	demo-seed	\N	\N
63	49	gram_morphology	\N	Bacilli	2026-09-18 11:43:41.702101+02	demo-seed	\N	\N
64	49	organism_identified	\N	Klebsiella pneumoniae	2026-09-18 11:43:41.702101+02	demo-seed	\N	\N
65	49	ast_result	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	2026-09-18 11:43:41.702101+02	demo-seed	\N	\N
66	50	gram_stain_reaction	\N	Gram negative	2026-09-18 11:43:41.703101+02	demo-seed	\N	\N
67	50	gram_morphology	\N	Bacilli	2026-09-18 11:43:41.703101+02	demo-seed	\N	\N
68	50	organism_identified	\N	Escherichia coli	2026-09-18 11:43:41.703101+02	demo-seed	\N	\N
69	51	gram_stain_reaction	\N	Gram positive	2026-09-18 11:43:41.703101+02	demo-seed	\N	\N
70	51	gram_morphology	\N	Cocci	2026-09-18 11:43:41.703101+02	demo-seed	\N	\N
71	51	organism_identified	\N	Staphylococcus epidermidis	2026-09-18 11:43:41.703101+02	demo-seed	\N	\N
72	52	gram_stain_reaction	\N	Gram positive	2026-09-18 11:43:41.704667+02	demo-seed	\N	\N
73	52	gram_morphology	\N	Diplococci	2026-09-18 11:43:41.704667+02	demo-seed	\N	\N
74	52	organism_identified	\N	Streptococcus agalactiae	2026-09-18 11:43:41.704667+02	demo-seed	\N	\N
75	53	gram_stain_reaction	\N	Gram positive	2026-09-18 11:43:41.705674+02	demo-seed	\N	\N
76	53	gram_morphology	\N	Cocci	2026-09-18 11:43:41.705674+02	demo-seed	\N	\N
77	53	organism_identified	\N	Staphylococcus aureus	2026-09-18 11:43:41.705674+02	demo-seed	\N	\N
78	54	gram_stain_reaction	\N	Gram negative	2026-09-18 11:43:41.705674+02	demo-seed	\N	\N
79	54	gram_morphology	\N	Bacilli	2026-09-18 11:43:41.705674+02	demo-seed	\N	\N
80	54	organism_identified	\N	Klebsiella pneumoniae	2026-09-18 11:43:41.706754+02	demo-seed	\N	\N
81	54	ast_result	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	2026-09-18 11:43:41.706754+02	demo-seed	\N	\N
\.


--
-- Data for Name: method_samples; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.method_samples (id, name, description, method_id, service_id, scheme_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, assigned_value_source, is_control) FROM stdin;
28	VL 2026-A3	HIV-1 VL panel sample 3 for Hologic Panther	7	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.694763+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
11	micro-CDL-2026-A-1	Ziehl-Neelsen panel sample 1	3	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.714232+02	\N	\N	\N	\N	f
12	micro-CDL-2026-A-2	Ziehl-Neelsen panel sample 2	3	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.716742+02	\N	\N	\N	\N	f
13	micro-CDL-2026-A-3	Ziehl-Neelsen panel sample 3	3	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.719254+02	\N	\N	\N	\N	f
14	micro-CDL-2026-A-4	Ziehl-Neelsen panel sample 4	3	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.722943+02	\N	\N	\N	\N	f
15	micro-CDL-2026-A-5	Ziehl-Neelsen panel sample 5	3	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.725339+02	\N	\N	\N	\N	f
1	ultra-CDL-2026-A-1	Ultra panel sample 1	1	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:42:36.463423+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
2	ultra-CDL-2026-A-2	Ultra panel sample 2	1	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:42:56.111238+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
3	ultra-CDL-2026-A-3	Ultra panel sample 3	1	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.689693+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
4	ultra-CDL-2026-A-4	Ultra panel sample 4	1	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.693699+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
5	ultra-CDL-2026-A-5	Ultra panel sample 5	1	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.695813+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
6	xdr-CDL-2026-A-1	XDR panel sample 1	2	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.699467+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
7	xdr-CDL-2026-A-2	XDR panel sample 2	2	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.702538+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
8	xdr-CDL-2026-A-3	XDR panel sample 3	2	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.705998+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
9	xdr-CDL-2026-A-4	XDR panel sample 4	2	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.70746+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
10	xdr-CDL-2026-A-5	XDR panel sample 5	2	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.709977+02	\N	2026-09-14 23:04:17.560071+02	\N	predefined	f
16	VL 2026-A1	HIV-1 VL panel sample 1 for Abbott m2000	5	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.676013+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
17	VL 2026-A2	HIV-1 VL panel sample 2 for Abbott m2000	5	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.678019+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
18	VL 2026-A3	HIV-1 VL panel sample 3 for Abbott m2000	5	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.680018+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
19	VL 2026-A4	HIV-1 VL panel sample 4 for Abbott m2000	5	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.682019+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
20	VL 2026-A5	HIV-1 VL panel sample 5 for Abbott m2000	5	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.68302+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
21	VL 2026-A1	HIV-1 VL panel sample 1 for Roche Cobas 6800	6	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.684327+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
22	VL 2026-A2	HIV-1 VL panel sample 2 for Roche Cobas 6800	6	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.685328+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
23	VL 2026-A3	HIV-1 VL panel sample 3 for Roche Cobas 6800	6	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.686831+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
24	VL 2026-A4	HIV-1 VL panel sample 4 for Roche Cobas 6800	6	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.687834+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
25	VL 2026-A5	HIV-1 VL panel sample 5 for Roche Cobas 6800	6	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.689838+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
26	VL 2026-A1	HIV-1 VL panel sample 1 for Hologic Panther	7	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.691843+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
27	VL 2026-A2	HIV-1 VL panel sample 2 for Hologic Panther	7	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.693253+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
29	VL 2026-A4	HIV-1 VL panel sample 4 for Hologic Panther	7	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.69577+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
30	VL 2026-A5	HIV-1 VL panel sample 5 for Hologic Panther	7	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.69682+02	\N	2026-09-14 23:04:17.560071+02	\N	consensus	f
31	Kit Negative Control	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.919214+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	t
32	Kit Positive Control	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.922227+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	t
33	2026-01	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.923227+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
34	2026-02	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.925227+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
35	2026-03	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.926226+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
36	2026-04	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.928739+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
37	2026-05	HIV-1 EID panel item for Cobas 4800	8	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.930036+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
38	Kit Negative Control	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.931037+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	t
39	Kit Positive Control	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.933122+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	t
40	2026-01	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.934129+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
41	2026-02	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.93513+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
42	2026-03	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.937385+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
43	2026-04	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.937385+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
44	2026-05	HIV-1 EID panel item for GeneXpert HIV-1 Qual	9	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.93991+02	\N	2026-09-14 23:42:00.204777+02	\N	predefined	f
45	NHRTIBACT A01-26	Urine, pathogen identification (Manual)	10	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.939079+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
46	NHRTIBACT B01-26	Peritoneal fluid, culture (Manual)	10	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.960702+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
47	NHRTIBACT C01-26	High vaginal swab, culture (Manual)	10	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.967722+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
48	NHRTIBACT D01-26	Wound swab, culture (Manual)	10	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.971728+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
49	NHRTIBACT E01-26	Sputum, culture and AST (Manual)	10	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.976722+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
50	NHRTIBACT A01-26	Urine, pathogen identification (Automated)	11	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.980242+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
51	NHRTIBACT B01-26	Peritoneal fluid, culture (Automated)	11	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.984752+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
52	NHRTIBACT C01-26	High vaginal swab, culture (Automated)	11	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.988842+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
53	NHRTIBACT D01-26	Wound swab, culture (Automated)	11	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.992343+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
54	NHRTIBACT E01-26	Sputum, culture and AST (Automated)	11	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.996343+02	\N	2026-09-18 09:37:50.114764+02	\N	predefined	f
\.


--
-- Data for Name: methods; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.methods (id, name, description, service_id, scheme_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, result_form) FROM stdin;
3	Ziehl-Neelsen	ZN stain microscopy	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.66817+02	\N	\N	\N	\N
4	LED Fluorescence	LED fluorescence microscopy	1	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.672272+02	\N	\N	\N	\N
1	Ultra	Xpert MTB/RIF Ultra	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:58:41.74217+02	\N	2026-09-14 20:23:25.660156+02	\N	tb_xpert_ultra
2	XDR	Xpert MTB/XDR	2	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:58:57.171916+02	\N	2026-09-14 20:23:25.665172+02	\N	tb_xpert_xdr
5	Abbott m2000	Abbott RealTime HIV-1 on m2000	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.668998+02	\N	\N	\N	hiv_vl
6	Roche Cobas 6800	Roche Cobas HIV-1 on the 6800 system	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.671998+02	\N	\N	\N	hiv_vl
7	Hologic Panther	Hologic Aptima HIV-1 Quant on Panther	3	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.674508+02	\N	\N	\N	hiv_vl
8	Cobas 4800	Roche Cobas 4800 HIV-1 Qualitative	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.914709+02	\N	\N	\N	hiv_eid
9	GeneXpert HIV-1 Qual	Cepheid Xpert HIV-1 Qual	4	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.916709+02	\N	\N	\N	hiv_eid
10	Manual	Manual bacteriology, conventional biochemicals and disk diffusion	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.927059+02	\N	\N	\N	bacteriology
11	Automated	Automated identification and susceptibility testing, e.g. Vitek 2	5	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.933079+02	\N	\N	\N	bacteriology
\.


--
-- Data for Name: providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.providers (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	CDL	Chest Diseases Laboratory	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:12:24.605112+02	\N	2026-09-14 20:23:25.631182+02	\N
2	Virology PT	Virology PT Scheme, Levy Mwanawasa University Teaching Hospital	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 21:33:41.766086+02	\N	2026-09-14 22:38:24.658444+02	\N
3	NHRTI PT Services	National Health Research and Training Institute, Ndola	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.901219+02	\N	\N	\N
\.


--
-- Data for Name: provinces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provinces (id, name, description, code, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Central	\N	ZM-02	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.859852+02	\N	\N	\N
2	Copperbelt	\N	ZM-08	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.866367+02	\N	\N	\N
3	Eastern	\N	ZM-03	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.869879+02	\N	\N	\N
4	Luapula	\N	ZM-04	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.873909+02	\N	\N	\N
5	Lusaka	\N	ZM-09	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.87691+02	\N	\N	\N
6	Muchinga	\N	ZM-10	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.879914+02	\N	\N	\N
7	Northern	\N	ZM-05	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.885427+02	\N	\N	\N
8	North-Western	\N	ZM-06	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.888609+02	\N	\N	\N
9	Southern	\N	ZM-07	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.891624+02	\N	\N	\N
10	Western	\N	ZM-01	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:20:02.89414+02	\N	\N	\N
\.


--
-- Data for Name: pt_cycle_samples; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_cycle_samples (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: pt_cycle_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_cycle_statuses (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Upcoming	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.128485+02	\N	\N	\N
2	Started	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.138955+02	\N	\N	\N
3	Samples Shipped	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.141476+02	\N	\N	\N
4	Report Available	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.145994+02	\N	\N	\N
5	Closed	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 14:08:34.15096+02	\N	\N	\N
\.


--
-- Data for Name: pt_cycles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_cycles (id, name, description, code, effective_date, scheme_id, pt_cyle_status_id, closing_date, shipping_date, reports_availability_date, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
11	Bacteriology Survey Two 2026	Bacteriology Survey Two 2026 proficiency testing round	BACT-02-2026	2026-08-20	4	3	2026-09-05	2026-09-08	2026-12-03	1	4	5	1	2026-09-18 11:43:51.573057+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:51.565538+02	\N	2026-09-18 11:43:51.740744+02	wanangwa@gmail.com
3	DTS Round One 2027	DTS Round One 2027 proficiency testing round	2027-A	2026-12-23	1	3	2026-11-13	2027-01-12	2027-03-13	1	4	5	1	2026-09-18 11:43:46.883383+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.871863+02	\N	2026-09-24 14:29:40.972212+02	nkoleevans@gmail.com
7	HIV-1 EID Round One 2026	HIV-1 EID Round One 2026 proficiency testing round	EID-2026-A	2026-03-28	3	5	2026-05-07	2026-06-06	2026-08-15	1	4	5	1	2026-09-18 11:43:48.733438+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.72336+02	\N	2026-09-18 11:43:49.824256+02	wanangwa@gmail.com
1	DTS Round One 2026	DTS Round One 2026 proficiency testing round	2026-A	2026-02-26	1	5	2026-04-07	2026-05-07	2026-07-16	1	4	5	1	2026-09-18 11:43:43.809233+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.796687+02	\N	2026-09-18 11:43:45.971769+02	wanangwa@gmail.com
2	DTS Round Two 2026	DTS Round Two 2026 proficiency testing round	2026-B	2026-08-15	1	3	2026-09-04	2026-09-09	2026-11-28	1	4	5	1	2026-09-18 11:43:45.988912+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:45.980911+02	\N	2026-09-18 11:43:46.178217+02	wanangwa@gmail.com
8	HIV-1 EID Round Two 2026	HIV-1 EID Round Two 2026 proficiency testing round	EID-2026-B	2026-08-27	3	3	2026-09-07	2026-09-11	2026-12-08	1	4	5	1	2026-09-18 11:43:49.836836+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:49.828283+02	\N	2026-09-18 11:43:50.025485+02	wanangwa@gmail.com
4	DTS Round Two 2027	DTS Round Two 2027 proficiency testing round	2027-B	2027-06-21	1	1	2027-05-12	2027-07-11	2027-09-09	1	4	5	1	2026-09-18 11:43:46.921337+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.913339+02	\N	2026-09-18 11:43:46.921337+02	nkoleevans@hotmail.com
9	HIV-1 VL Round One 2027	HIV-1 VL Round One 2027 proficiency testing round	VL-2027-A	2027-01-02	2	2	2026-11-23	2027-01-22	2027-03-23	1	4	5	1	2026-09-18 11:43:50.532707+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.52718+02	\N	2026-09-18 11:43:50.540224+02	wanangwa@gmail.com
5	HIV-1 VL Round One 2026	HIV-1 VL Round One 2026 proficiency testing round	VL-2026-A	2026-03-18	2	5	2026-04-27	2026-05-27	2026-08-05	1	4	5	1	2026-09-18 11:43:46.931344+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.925338+02	\N	2026-09-18 11:43:48.061638+02	wanangwa@gmail.com
6	HIV-1 VL Round Two 2026	HIV-1 VL Round Two 2026 proficiency testing round	VL-2026-B	2026-08-25	2	3	2026-09-06	2026-09-10	2026-12-03	1	4	5	1	2026-09-18 11:43:48.073635+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:48.066637+02	\N	2026-09-18 11:43:48.239691+02	wanangwa@gmail.com
10	Bacteriology Survey One 2026	Bacteriology Survey One 2026 proficiency testing round	BACT-01-2026	2026-04-07	4	5	2026-05-17	2026-06-11	2026-08-15	1	4	5	1	2026-09-18 11:43:50.548231+02	nkoleevans@hotmail.com	Calendar confirmed	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:50.542224+02	\N	2026-09-18 11:43:51.560974+02	wanangwa@gmail.com
\.


--
-- Data for Name: pt_enrollment_performance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_enrollment_performance (id, pt_cycle_id, lab_id, enrollment_id, method_id, service_id, scheme_id, result_form, report_number, attributes_total, attributes_evaluated, acceptable_count, warning_count, unacceptable_count, not_reported_count, total_score, max_score, percent_score, overall_performance, reason_for_no_evaluation, frozen_at, frozen_by, created_at, created_by, updated_at, updated_by) FROM stdin;
1	1	1	1	1	2	1	tb_xpert_ultra	2026-A/REG0001	10	8	7	0	1	2	14	20	0.7	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.766236+02	wanangwa@gmail.com	\N	\N
2	1	5	8	1	2	1	tb_xpert_ultra	2026-A/REG0005	10	8	8	0	0	2	16	20	0.8	Satisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.772807+02	wanangwa@gmail.com	\N	\N
3	1	6	9	1	2	1	tb_xpert_ultra	2026-A/REG0006	10	8	7	0	1	2	14	20	0.7	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.773953+02	wanangwa@gmail.com	\N	\N
4	1	2	3	1	2	1	tb_xpert_ultra	2026-A/REG0002	10	8	8	0	0	2	16	20	0.8	Satisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.774951+02	wanangwa@gmail.com	\N	\N
5	1	3	5	1	2	1	tb_xpert_ultra	2026-A/REG0003	10	8	7	0	1	2	14	20	0.7	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.775945+02	wanangwa@gmail.com	\N	\N
6	1	4	6	1	2	1	tb_xpert_ultra	2026-A/REG0004	10	8	7	0	1	2	14	20	0.7	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.775945+02	wanangwa@gmail.com	\N	\N
7	1	4	7	2	2	1	tb_xpert_xdr	2026-A/REG0004	25	20	19	0	1	5	38	50	0.76	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.776945+02	wanangwa@gmail.com	\N	\N
8	1	1	2	2	2	1	tb_xpert_xdr	2026-A/REG0001	25	20	19	0	1	5	38	50	0.76	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.776945+02	wanangwa@gmail.com	\N	\N
9	1	6	10	2	2	1	tb_xpert_xdr	2026-A/REG0006	25	20	19	0	1	5	38	50	0.76	Unsatisfactory	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.77795+02	wanangwa@gmail.com	\N	\N
15	7	1	34	9	4	3	hiv_eid	EID-2026-A/REG0001	5	5	4	0	1	0	80	100	0.8	Unsatisfactory	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.704847+02	wanangwa@gmail.com	\N	\N
16	7	13	37	9	4	3	hiv_eid	EID-2026-A/REG0013	5	5	5	0	0	0	100	100	1	Satisfactory	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.711844+02	wanangwa@gmail.com	\N	\N
17	7	11	35	8	4	3	hiv_eid	EID-2026-A/REG0011	5	5	5	0	0	0	100	100	1	Satisfactory	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.712844+02	wanangwa@gmail.com	\N	\N
18	7	12	36	8	4	3	hiv_eid	EID-2026-A/REG0012	5	4	4	0	0	1	80	100	0.8	Unsatisfactory	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.713847+02	wanangwa@gmail.com	\N	\N
19	10	14	42	10	5	4	bacteriology	BACT-01-2026/REG0014	20	16	15	0	1	4	80	100	0.8	Unsatisfactory	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.459383+02	wanangwa@gmail.com	\N	\N
20	10	15	43	10	5	4	bacteriology	BACT-01-2026/REG0015	20	16	15	0	1	4	90	100	0.9	Unsatisfactory	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.460392+02	wanangwa@gmail.com	\N	\N
21	10	15	44	11	5	4	bacteriology	BACT-01-2026/REG0015	20	16	16	0	0	4	100	100	1	Satisfactory	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.460392+02	wanangwa@gmail.com	\N	\N
22	10	16	45	11	5	4	bacteriology	BACT-01-2026/REG0016	20	13	13	0	0	7	84	100	0.84	Unsatisfactory	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.461391+02	wanangwa@gmail.com	\N	\N
23	5	1	24	7	3	2	hiv_vl	VL-2026-A/REG0001	5	3	3	0	0	2	6	6	1	Satisfactory	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.870528+02	wanangwa@gmail.com	\N	\N
24	5	10	26	6	3	2	hiv_vl	VL-2026-A/REG0010	5	3	3	0	0	2	6	6	1	Satisfactory	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.872586+02	wanangwa@gmail.com	\N	\N
25	5	11	28	7	3	2	hiv_vl	VL-2026-A/REG0011	5	3	3	0	0	2	6	6	1	Satisfactory	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.874597+02	wanangwa@gmail.com	\N	\N
26	5	9	25	5	3	2	hiv_vl	VL-2026-A/REG0009	5	3	2	0	1	2	4	6	0.6667	Unsatisfactory	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.875592+02	wanangwa@gmail.com	\N	\N
27	5	11	27	5	3	2	hiv_vl	VL-2026-A/REG0011	5	3	2	0	1	2	4	6	0.6667	Unsatisfactory	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.876594+02	wanangwa@gmail.com	\N	\N
\.


--
-- Data for Name: pt_result_evaluations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_result_evaluations (id, pt_cycle_id, lab_id, enrollment_id, method_sample_id, method_id, service_id, scheme_id, result_form, result_id, attribute, attribute_label, reported_numeric, reported_text, assigned_numeric, assigned_text, group_mean, robust_sd, deviation, z_score, score, max_score, grade, evaluated, not_evaluated_reason, frozen_at, frozen_by, created_at, created_by, updated_at, updated_by) FROM stdin;
1	1	1	1	1	1	2	1	tb_xpert_ultra	26	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.78095+02	wanangwa@gmail.com	\N	\N
2	1	5	8	1	1	2	1	tb_xpert_ultra	6	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.808383+02	wanangwa@gmail.com	\N	\N
3	1	6	9	1	1	2	1	tb_xpert_ultra	1	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.809381+02	wanangwa@gmail.com	\N	\N
4	1	2	3	1	1	2	1	tb_xpert_ultra	21	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.810379+02	wanangwa@gmail.com	\N	\N
5	1	3	5	1	1	2	1	tb_xpert_ultra	16	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.811378+02	wanangwa@gmail.com	\N	\N
6	1	4	6	1	1	2	1	tb_xpert_ultra	11	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.812379+02	wanangwa@gmail.com	\N	\N
7	1	1	1	1	1	2	1	tb_xpert_ultra	26	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.814378+02	wanangwa@gmail.com	\N	\N
8	1	5	8	1	1	2	1	tb_xpert_ultra	6	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.815379+02	wanangwa@gmail.com	\N	\N
9	1	6	9	1	1	2	1	tb_xpert_ultra	1	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.815379+02	wanangwa@gmail.com	\N	\N
10	1	2	3	1	1	2	1	tb_xpert_ultra	21	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.816379+02	wanangwa@gmail.com	\N	\N
11	1	3	5	1	1	2	1	tb_xpert_ultra	16	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.817379+02	wanangwa@gmail.com	\N	\N
12	1	4	6	1	1	2	1	tb_xpert_ultra	11	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.81789+02	wanangwa@gmail.com	\N	\N
13	1	1	1	2	1	2	1	tb_xpert_ultra	27	tb_detection_result	TB Detection Result	\N	HIGH	\N	HIGH	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.81789+02	wanangwa@gmail.com	\N	\N
14	1	2	3	2	1	2	1	tb_xpert_ultra	22	tb_detection_result	TB Detection Result	\N	HIGH	\N	HIGH	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.818925+02	wanangwa@gmail.com	\N	\N
15	1	3	5	2	1	2	1	tb_xpert_ultra	17	tb_detection_result	TB Detection Result	\N	MEDIUM	\N	HIGH	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.818925+02	wanangwa@gmail.com	\N	\N
16	1	4	6	2	1	2	1	tb_xpert_ultra	12	tb_detection_result	TB Detection Result	\N	HIGH	\N	HIGH	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.818925+02	wanangwa@gmail.com	\N	\N
17	1	5	8	2	1	2	1	tb_xpert_ultra	7	tb_detection_result	TB Detection Result	\N	HIGH	\N	HIGH	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.819926+02	wanangwa@gmail.com	\N	\N
18	1	6	9	2	1	2	1	tb_xpert_ultra	2	tb_detection_result	TB Detection Result	\N	HIGH	\N	HIGH	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.819926+02	wanangwa@gmail.com	\N	\N
19	1	1	1	2	1	2	1	tb_xpert_ultra	27	rif_result	Rif Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.819926+02	wanangwa@gmail.com	\N	\N
20	1	2	3	2	1	2	1	tb_xpert_ultra	22	rif_result	Rif Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.820924+02	wanangwa@gmail.com	\N	\N
21	1	3	5	2	1	2	1	tb_xpert_ultra	17	rif_result	Rif Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.820924+02	wanangwa@gmail.com	\N	\N
22	1	4	6	2	1	2	1	tb_xpert_ultra	12	rif_result	Rif Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.820924+02	wanangwa@gmail.com	\N	\N
23	1	5	8	2	1	2	1	tb_xpert_ultra	7	rif_result	Rif Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.826911+02	wanangwa@gmail.com	\N	\N
24	1	6	9	2	1	2	1	tb_xpert_ultra	2	rif_result	Rif Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.826911+02	wanangwa@gmail.com	\N	\N
25	1	1	1	4	1	2	1	tb_xpert_ultra	29	tb_detection_result	TB Detection Result	\N	TRACE	\N	TRACE	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.827904+02	wanangwa@gmail.com	\N	\N
26	1	2	3	4	1	2	1	tb_xpert_ultra	24	tb_detection_result	TB Detection Result	\N	TRACE	\N	TRACE	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.827904+02	wanangwa@gmail.com	\N	\N
27	1	3	5	4	1	2	1	tb_xpert_ultra	19	tb_detection_result	TB Detection Result	\N	TRACE	\N	TRACE	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.827904+02	wanangwa@gmail.com	\N	\N
28	1	4	6	4	1	2	1	tb_xpert_ultra	14	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	TRACE	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.827904+02	wanangwa@gmail.com	\N	\N
29	1	5	8	4	1	2	1	tb_xpert_ultra	9	tb_detection_result	TB Detection Result	\N	TRACE	\N	TRACE	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.827904+02	wanangwa@gmail.com	\N	\N
30	1	6	9	4	1	2	1	tb_xpert_ultra	4	tb_detection_result	TB Detection Result	\N	TRACE	\N	TRACE	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.829413+02	wanangwa@gmail.com	\N	\N
31	1	1	1	4	1	2	1	tb_xpert_ultra	29	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.829413+02	wanangwa@gmail.com	\N	\N
32	1	2	3	4	1	2	1	tb_xpert_ultra	24	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.829413+02	wanangwa@gmail.com	\N	\N
33	1	3	5	4	1	2	1	tb_xpert_ultra	19	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.830425+02	wanangwa@gmail.com	\N	\N
34	1	4	6	4	1	2	1	tb_xpert_ultra	14	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.830425+02	wanangwa@gmail.com	\N	\N
35	1	5	8	4	1	2	1	tb_xpert_ultra	9	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.834942+02	wanangwa@gmail.com	\N	\N
36	1	6	9	4	1	2	1	tb_xpert_ultra	4	rif_result	Rif Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.83594+02	wanangwa@gmail.com	\N	\N
37	1	1	1	5	1	2	1	tb_xpert_ultra	30	tb_detection_result	TB Detection Result	\N	\N	\N	LOW	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.83594+02	wanangwa@gmail.com	\N	\N
38	1	2	3	5	1	2	1	tb_xpert_ultra	25	tb_detection_result	TB Detection Result	\N	\N	\N	LOW	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.840027+02	wanangwa@gmail.com	\N	\N
39	1	3	5	5	1	2	1	tb_xpert_ultra	20	tb_detection_result	TB Detection Result	\N	\N	\N	LOW	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.841027+02	wanangwa@gmail.com	\N	\N
40	1	5	8	5	1	2	1	tb_xpert_ultra	10	tb_detection_result	TB Detection Result	\N	\N	\N	LOW	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.841027+02	wanangwa@gmail.com	\N	\N
41	1	6	9	5	1	2	1	tb_xpert_ultra	5	tb_detection_result	TB Detection Result	\N	\N	\N	LOW	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.842027+02	wanangwa@gmail.com	\N	\N
42	1	4	6	5	1	2	1	tb_xpert_ultra	15	tb_detection_result	TB Detection Result	\N	\N	\N	LOW	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.842027+02	wanangwa@gmail.com	\N	\N
43	1	1	1	5	1	2	1	tb_xpert_ultra	30	rif_result	Rif Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.84303+02	wanangwa@gmail.com	\N	\N
44	1	2	3	5	1	2	1	tb_xpert_ultra	25	rif_result	Rif Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.845028+02	wanangwa@gmail.com	\N	\N
45	1	3	5	5	1	2	1	tb_xpert_ultra	20	rif_result	Rif Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.845028+02	wanangwa@gmail.com	\N	\N
46	1	5	8	5	1	2	1	tb_xpert_ultra	10	rif_result	Rif Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.846027+02	wanangwa@gmail.com	\N	\N
47	1	6	9	5	1	2	1	tb_xpert_ultra	5	rif_result	Rif Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.846027+02	wanangwa@gmail.com	\N	\N
48	1	4	6	5	1	2	1	tb_xpert_ultra	15	rif_result	Rif Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.847029+02	wanangwa@gmail.com	\N	\N
49	1	5	8	3	1	2	1	tb_xpert_ultra	8	tb_detection_result	TB Detection Result	\N	MEDIUM	\N	MEDIUM	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.847029+02	wanangwa@gmail.com	\N	\N
50	1	6	9	3	1	2	1	tb_xpert_ultra	3	tb_detection_result	TB Detection Result	\N	LOW	\N	MEDIUM	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.849028+02	wanangwa@gmail.com	\N	\N
51	1	1	1	3	1	2	1	tb_xpert_ultra	28	tb_detection_result	TB Detection Result	\N	LOW	\N	MEDIUM	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.850036+02	wanangwa@gmail.com	\N	\N
52	1	2	3	3	1	2	1	tb_xpert_ultra	23	tb_detection_result	TB Detection Result	\N	MEDIUM	\N	MEDIUM	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.850036+02	wanangwa@gmail.com	\N	\N
53	1	3	5	3	1	2	1	tb_xpert_ultra	18	tb_detection_result	TB Detection Result	\N	MEDIUM	\N	MEDIUM	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.85103+02	wanangwa@gmail.com	\N	\N
54	1	4	6	3	1	2	1	tb_xpert_ultra	13	tb_detection_result	TB Detection Result	\N	MEDIUM	\N	MEDIUM	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.852033+02	wanangwa@gmail.com	\N	\N
55	1	5	8	3	1	2	1	tb_xpert_ultra	8	rif_result	Rif Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.852033+02	wanangwa@gmail.com	\N	\N
56	1	6	9	3	1	2	1	tb_xpert_ultra	3	rif_result	Rif Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.852033+02	wanangwa@gmail.com	\N	\N
57	1	1	1	3	1	2	1	tb_xpert_ultra	28	rif_result	Rif Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.853026+02	wanangwa@gmail.com	\N	\N
58	1	2	3	3	1	2	1	tb_xpert_ultra	23	rif_result	Rif Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.853026+02	wanangwa@gmail.com	\N	\N
59	1	3	5	3	1	2	1	tb_xpert_ultra	18	rif_result	Rif Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.857032+02	wanangwa@gmail.com	\N	\N
60	1	4	6	3	1	2	1	tb_xpert_ultra	13	rif_result	Rif Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.858033+02	wanangwa@gmail.com	\N	\N
61	1	4	7	8	2	2	1	tb_xpert_xdr	8	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.859034+02	wanangwa@gmail.com	\N	\N
62	1	1	2	8	2	2	1	tb_xpert_xdr	13	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.860035+02	wanangwa@gmail.com	\N	\N
63	1	6	10	8	2	2	1	tb_xpert_xdr	3	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.860035+02	wanangwa@gmail.com	\N	\N
64	1	4	7	8	2	2	1	tb_xpert_xdr	8	inh_result	INH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.861034+02	wanangwa@gmail.com	\N	\N
65	1	1	2	8	2	2	1	tb_xpert_xdr	13	inh_result	INH Result	\N	NOT DETECTED	\N	DETECTED	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.861034+02	wanangwa@gmail.com	\N	\N
66	1	6	10	8	2	2	1	tb_xpert_xdr	3	inh_result	INH Result	\N	NOT DETECTED	\N	DETECTED	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.864034+02	wanangwa@gmail.com	\N	\N
67	1	4	7	8	2	2	1	tb_xpert_xdr	8	flq_result	FLQ Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.865036+02	wanangwa@gmail.com	\N	\N
68	1	1	2	8	2	2	1	tb_xpert_xdr	13	flq_result	FLQ Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.865036+02	wanangwa@gmail.com	\N	\N
69	1	6	10	8	2	2	1	tb_xpert_xdr	3	flq_result	FLQ Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.866033+02	wanangwa@gmail.com	\N	\N
70	1	4	7	8	2	2	1	tb_xpert_xdr	8	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.866033+02	wanangwa@gmail.com	\N	\N
71	1	1	2	8	2	2	1	tb_xpert_xdr	13	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.867032+02	wanangwa@gmail.com	\N	\N
72	1	6	10	8	2	2	1	tb_xpert_xdr	3	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.867032+02	wanangwa@gmail.com	\N	\N
73	1	4	7	8	2	2	1	tb_xpert_xdr	8	eth_result	ETH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.870555+02	wanangwa@gmail.com	\N	\N
74	1	1	2	8	2	2	1	tb_xpert_xdr	13	eth_result	ETH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.871548+02	wanangwa@gmail.com	\N	\N
75	1	6	10	8	2	2	1	tb_xpert_xdr	3	eth_result	ETH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.871548+02	wanangwa@gmail.com	\N	\N
76	1	1	2	6	2	2	1	tb_xpert_xdr	11	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.873057+02	wanangwa@gmail.com	\N	\N
77	1	6	10	6	2	2	1	tb_xpert_xdr	1	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.87407+02	wanangwa@gmail.com	\N	\N
78	1	4	7	6	2	2	1	tb_xpert_xdr	6	tb_detection_result	TB Detection Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.87407+02	wanangwa@gmail.com	\N	\N
79	1	1	2	6	2	2	1	tb_xpert_xdr	11	inh_result	INH Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.879065+02	wanangwa@gmail.com	\N	\N
80	1	6	10	6	2	2	1	tb_xpert_xdr	1	inh_result	INH Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.880068+02	wanangwa@gmail.com	\N	\N
81	1	4	7	6	2	2	1	tb_xpert_xdr	6	inh_result	INH Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.88107+02	wanangwa@gmail.com	\N	\N
82	1	1	2	6	2	2	1	tb_xpert_xdr	11	flq_result	FLQ Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.88107+02	wanangwa@gmail.com	\N	\N
83	1	6	10	6	2	2	1	tb_xpert_xdr	1	flq_result	FLQ Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.882065+02	wanangwa@gmail.com	\N	\N
84	1	4	7	6	2	2	1	tb_xpert_xdr	6	flq_result	FLQ Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.883064+02	wanangwa@gmail.com	\N	\N
85	1	1	2	6	2	2	1	tb_xpert_xdr	11	amk_result	AMK Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.884064+02	wanangwa@gmail.com	\N	\N
86	1	6	10	6	2	2	1	tb_xpert_xdr	1	amk_result	AMK Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.885064+02	wanangwa@gmail.com	\N	\N
87	1	4	7	6	2	2	1	tb_xpert_xdr	6	amk_result	AMK Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.885064+02	wanangwa@gmail.com	\N	\N
88	1	1	2	6	2	2	1	tb_xpert_xdr	11	eth_result	ETH Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.886064+02	wanangwa@gmail.com	\N	\N
89	1	6	10	6	2	2	1	tb_xpert_xdr	1	eth_result	ETH Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.886064+02	wanangwa@gmail.com	\N	\N
90	1	4	7	6	2	2	1	tb_xpert_xdr	6	eth_result	ETH Result	\N	N/A	\N	N/A	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.887065+02	wanangwa@gmail.com	\N	\N
91	1	1	2	10	2	2	1	tb_xpert_xdr	15	tb_detection_result	TB Detection Result	\N	\N	\N	DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.892064+02	wanangwa@gmail.com	\N	\N
92	1	4	7	10	2	2	1	tb_xpert_xdr	10	tb_detection_result	TB Detection Result	\N	\N	\N	DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.892064+02	wanangwa@gmail.com	\N	\N
93	1	6	10	10	2	2	1	tb_xpert_xdr	5	tb_detection_result	TB Detection Result	\N	\N	\N	DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.893067+02	wanangwa@gmail.com	\N	\N
94	1	1	2	10	2	2	1	tb_xpert_xdr	15	inh_result	INH Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.894064+02	wanangwa@gmail.com	\N	\N
95	1	4	7	10	2	2	1	tb_xpert_xdr	10	inh_result	INH Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.894064+02	wanangwa@gmail.com	\N	\N
96	1	6	10	10	2	2	1	tb_xpert_xdr	5	inh_result	INH Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.895065+02	wanangwa@gmail.com	\N	\N
97	1	1	2	10	2	2	1	tb_xpert_xdr	15	flq_result	FLQ Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.896064+02	wanangwa@gmail.com	\N	\N
98	1	4	7	10	2	2	1	tb_xpert_xdr	10	flq_result	FLQ Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.89707+02	wanangwa@gmail.com	\N	\N
99	1	6	10	10	2	2	1	tb_xpert_xdr	5	flq_result	FLQ Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.898074+02	wanangwa@gmail.com	\N	\N
100	1	1	2	10	2	2	1	tb_xpert_xdr	15	amk_result	AMK Result	\N	\N	\N	DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.899074+02	wanangwa@gmail.com	\N	\N
101	1	4	7	10	2	2	1	tb_xpert_xdr	10	amk_result	AMK Result	\N	\N	\N	DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.900069+02	wanangwa@gmail.com	\N	\N
102	1	6	10	10	2	2	1	tb_xpert_xdr	5	amk_result	AMK Result	\N	\N	\N	DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.901072+02	wanangwa@gmail.com	\N	\N
103	1	1	2	10	2	2	1	tb_xpert_xdr	15	eth_result	ETH Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.904075+02	wanangwa@gmail.com	\N	\N
104	1	4	7	10	2	2	1	tb_xpert_xdr	10	eth_result	ETH Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.906077+02	wanangwa@gmail.com	\N	\N
105	1	6	10	10	2	2	1	tb_xpert_xdr	5	eth_result	ETH Result	\N	\N	\N	NOT DETECTED	\N	\N	\N	\N	0	2	Not Evaluated	f	ERROR	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.907081+02	wanangwa@gmail.com	\N	\N
106	1	1	2	7	2	2	1	tb_xpert_xdr	12	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.908079+02	wanangwa@gmail.com	\N	\N
107	1	4	7	7	2	2	1	tb_xpert_xdr	7	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.908079+02	wanangwa@gmail.com	\N	\N
108	1	6	10	7	2	2	1	tb_xpert_xdr	2	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.910082+02	wanangwa@gmail.com	\N	\N
109	1	1	2	7	2	2	1	tb_xpert_xdr	12	inh_result	INH Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.912075+02	wanangwa@gmail.com	\N	\N
110	1	4	7	7	2	2	1	tb_xpert_xdr	7	inh_result	INH Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.913076+02	wanangwa@gmail.com	\N	\N
111	1	6	10	7	2	2	1	tb_xpert_xdr	2	inh_result	INH Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.913076+02	wanangwa@gmail.com	\N	\N
112	1	1	2	7	2	2	1	tb_xpert_xdr	12	flq_result	FLQ Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.914078+02	wanangwa@gmail.com	\N	\N
113	1	4	7	7	2	2	1	tb_xpert_xdr	7	flq_result	FLQ Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.915078+02	wanangwa@gmail.com	\N	\N
114	1	6	10	7	2	2	1	tb_xpert_xdr	2	flq_result	FLQ Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.916079+02	wanangwa@gmail.com	\N	\N
115	1	1	2	7	2	2	1	tb_xpert_xdr	12	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.916079+02	wanangwa@gmail.com	\N	\N
116	1	4	7	7	2	2	1	tb_xpert_xdr	7	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.917073+02	wanangwa@gmail.com	\N	\N
117	1	6	10	7	2	2	1	tb_xpert_xdr	2	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.917073+02	wanangwa@gmail.com	\N	\N
118	1	1	2	7	2	2	1	tb_xpert_xdr	12	eth_result	ETH Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.918075+02	wanangwa@gmail.com	\N	\N
119	1	4	7	7	2	2	1	tb_xpert_xdr	7	eth_result	ETH Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.919078+02	wanangwa@gmail.com	\N	\N
120	1	6	10	7	2	2	1	tb_xpert_xdr	2	eth_result	ETH Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.919589+02	wanangwa@gmail.com	\N	\N
121	1	1	2	9	2	2	1	tb_xpert_xdr	14	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.919589+02	wanangwa@gmail.com	\N	\N
122	1	4	7	9	2	2	1	tb_xpert_xdr	9	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.920591+02	wanangwa@gmail.com	\N	\N
123	1	6	10	9	2	2	1	tb_xpert_xdr	4	tb_detection_result	TB Detection Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.920591+02	wanangwa@gmail.com	\N	\N
124	1	1	2	9	2	2	1	tb_xpert_xdr	14	inh_result	INH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.921591+02	wanangwa@gmail.com	\N	\N
125	1	4	7	9	2	2	1	tb_xpert_xdr	9	inh_result	INH Result	\N	NOT DETECTED	\N	DETECTED	\N	\N	\N	\N	0	2	Unacceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.923096+02	wanangwa@gmail.com	\N	\N
126	1	6	10	9	2	2	1	tb_xpert_xdr	4	inh_result	INH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.923096+02	wanangwa@gmail.com	\N	\N
127	1	1	2	9	2	2	1	tb_xpert_xdr	14	flq_result	FLQ Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.924103+02	wanangwa@gmail.com	\N	\N
128	1	4	7	9	2	2	1	tb_xpert_xdr	9	flq_result	FLQ Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.924103+02	wanangwa@gmail.com	\N	\N
129	1	6	10	9	2	2	1	tb_xpert_xdr	4	flq_result	FLQ Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.924103+02	wanangwa@gmail.com	\N	\N
130	1	1	2	9	2	2	1	tb_xpert_xdr	14	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.925103+02	wanangwa@gmail.com	\N	\N
131	1	4	7	9	2	2	1	tb_xpert_xdr	9	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.925103+02	wanangwa@gmail.com	\N	\N
132	1	6	10	9	2	2	1	tb_xpert_xdr	4	amk_result	AMK Result	\N	NOT DETECTED	\N	NOT DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.92711+02	wanangwa@gmail.com	\N	\N
133	1	1	2	9	2	2	1	tb_xpert_xdr	14	eth_result	ETH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.92711+02	wanangwa@gmail.com	\N	\N
134	1	4	7	9	2	2	1	tb_xpert_xdr	9	eth_result	ETH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.92811+02	wanangwa@gmail.com	\N	\N
135	1	6	10	9	2	2	1	tb_xpert_xdr	4	eth_result	ETH Result	\N	DETECTED	\N	DETECTED	\N	\N	\N	\N	2	2	Acceptable	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.92811+02	wanangwa@gmail.com	\N	\N
161	7	1	34	40	9	4	3	hiv_eid	1	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.714845+02	wanangwa@gmail.com	\N	\N
162	7	13	37	40	9	4	3	hiv_eid	8	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.715846+02	wanangwa@gmail.com	\N	\N
163	7	11	35	33	8	4	3	hiv_eid	22	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.724868+02	wanangwa@gmail.com	\N	\N
164	7	12	36	33	8	4	3	hiv_eid	15	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.725871+02	wanangwa@gmail.com	\N	\N
165	7	1	34	42	9	4	3	hiv_eid	3	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	0	20	Unacceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.725871+02	wanangwa@gmail.com	\N	\N
166	7	13	37	42	9	4	3	hiv_eid	10	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.726872+02	wanangwa@gmail.com	\N	\N
167	7	11	35	35	8	4	3	hiv_eid	24	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.727868+02	wanangwa@gmail.com	\N	\N
168	7	12	36	35	8	4	3	hiv_eid	17	hiv_result	Your Result	\N	\N	\N	HIV-1 Not Detected	\N	\N	\N	\N	0	20	Not Evaluated	f	Insufficient sample volume received	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.736409+02	wanangwa@gmail.com	\N	\N
169	7	1	34	44	9	4	3	hiv_eid	5	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.737408+02	wanangwa@gmail.com	\N	\N
170	7	11	35	37	8	4	3	hiv_eid	26	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.738411+02	wanangwa@gmail.com	\N	\N
171	7	13	37	44	9	4	3	hiv_eid	12	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.739409+02	wanangwa@gmail.com	\N	\N
172	7	12	36	37	8	4	3	hiv_eid	19	hiv_result	Your Result	\N	HIV-1 Detected	\N	HIV-1 Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.740409+02	wanangwa@gmail.com	\N	\N
173	7	11	35	34	8	4	3	hiv_eid	23	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.749932+02	wanangwa@gmail.com	\N	\N
174	7	12	36	34	8	4	3	hiv_eid	16	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.753455+02	wanangwa@gmail.com	\N	\N
175	7	1	34	41	9	4	3	hiv_eid	2	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.755512+02	wanangwa@gmail.com	\N	\N
176	7	13	37	41	9	4	3	hiv_eid	9	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.759524+02	wanangwa@gmail.com	\N	\N
177	7	11	35	36	8	4	3	hiv_eid	25	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.808673+02	wanangwa@gmail.com	\N	\N
178	7	12	36	36	8	4	3	hiv_eid	18	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.811208+02	wanangwa@gmail.com	\N	\N
179	7	1	34	43	9	4	3	hiv_eid	4	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.811208+02	wanangwa@gmail.com	\N	\N
180	7	13	37	43	9	4	3	hiv_eid	11	hiv_result	Your Result	\N	HIV-1 Not Detected	\N	HIV-1 Not Detected	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.812218+02	wanangwa@gmail.com	\N	\N
181	10	14	42	48	10	5	4	bacteriology	19	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.46239+02	wanangwa@gmail.com	\N	\N
182	10	15	43	48	10	5	4	bacteriology	14	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.463902+02	wanangwa@gmail.com	\N	\N
183	10	15	44	53	11	5	4	bacteriology	9	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.46641+02	wanangwa@gmail.com	\N	\N
184	10	16	45	53	11	5	4	bacteriology	4	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.467418+02	wanangwa@gmail.com	\N	\N
185	10	14	42	48	10	5	4	bacteriology	19	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.468422+02	wanangwa@gmail.com	\N	\N
186	10	15	43	48	10	5	4	bacteriology	14	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.468422+02	wanangwa@gmail.com	\N	\N
187	10	15	44	53	11	5	4	bacteriology	9	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.46942+02	wanangwa@gmail.com	\N	\N
188	10	16	45	53	11	5	4	bacteriology	4	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.46942+02	wanangwa@gmail.com	\N	\N
189	10	14	42	48	10	5	4	bacteriology	19	organism_identified	Bacterial Identification	\N	Staphylococcus aureus	\N	Staphylococcus aureus	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.471419+02	wanangwa@gmail.com	\N	\N
190	10	15	43	48	10	5	4	bacteriology	14	organism_identified	Bacterial Identification	\N	Staphylococcus aureus	\N	Staphylococcus aureus	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.472417+02	wanangwa@gmail.com	\N	\N
191	10	15	44	53	11	5	4	bacteriology	9	organism_identified	Bacterial Identification	\N	Staphylococcus aureus	\N	Staphylococcus aureus	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.473431+02	wanangwa@gmail.com	\N	\N
192	10	16	45	53	11	5	4	bacteriology	4	organism_identified	Bacterial Identification	\N	Staphylococcus aureus	\N	Staphylococcus aureus	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.473431+02	wanangwa@gmail.com	\N	\N
193	10	14	42	48	10	5	4	bacteriology	19	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.47442+02	wanangwa@gmail.com	\N	\N
194	10	15	43	48	10	5	4	bacteriology	14	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.474931+02	wanangwa@gmail.com	\N	\N
195	10	15	44	53	11	5	4	bacteriology	9	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.474931+02	wanangwa@gmail.com	\N	\N
196	10	16	45	53	11	5	4	bacteriology	4	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.475938+02	wanangwa@gmail.com	\N	\N
197	10	14	42	45	10	5	4	bacteriology	16	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.478447+02	wanangwa@gmail.com	\N	\N
198	10	15	43	45	10	5	4	bacteriology	11	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.479456+02	wanangwa@gmail.com	\N	\N
199	10	15	44	50	11	5	4	bacteriology	6	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.479456+02	wanangwa@gmail.com	\N	\N
200	10	16	45	50	11	5	4	bacteriology	1	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.480674+02	wanangwa@gmail.com	\N	\N
201	10	14	42	45	10	5	4	bacteriology	16	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.481672+02	wanangwa@gmail.com	\N	\N
202	10	15	43	45	10	5	4	bacteriology	11	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.484675+02	wanangwa@gmail.com	\N	\N
203	10	15	44	50	11	5	4	bacteriology	6	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.485673+02	wanangwa@gmail.com	\N	\N
204	10	16	45	50	11	5	4	bacteriology	1	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.485673+02	wanangwa@gmail.com	\N	\N
205	10	14	42	45	10	5	4	bacteriology	16	organism_identified	Bacterial Identification	\N	Escherichia coli	\N	Escherichia coli	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.486673+02	wanangwa@gmail.com	\N	\N
206	10	15	43	45	10	5	4	bacteriology	11	organism_identified	Bacterial Identification	\N	Escherichia coli	\N	Escherichia coli	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.486673+02	wanangwa@gmail.com	\N	\N
207	10	15	44	50	11	5	4	bacteriology	6	organism_identified	Bacterial Identification	\N	Escherichia coli	\N	Escherichia coli	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.487672+02	wanangwa@gmail.com	\N	\N
208	10	16	45	50	11	5	4	bacteriology	1	organism_identified	Bacterial Identification	\N	Escherichia coli	\N	Escherichia coli	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.491187+02	wanangwa@gmail.com	\N	\N
209	10	14	42	45	10	5	4	bacteriology	16	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.491187+02	wanangwa@gmail.com	\N	\N
210	10	15	43	45	10	5	4	bacteriology	11	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.49272+02	wanangwa@gmail.com	\N	\N
211	10	15	44	50	11	5	4	bacteriology	6	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.49272+02	wanangwa@gmail.com	\N	\N
212	10	16	45	50	11	5	4	bacteriology	1	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.493736+02	wanangwa@gmail.com	\N	\N
213	10	14	42	47	10	5	4	bacteriology	18	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.496239+02	wanangwa@gmail.com	\N	\N
214	10	15	43	47	10	5	4	bacteriology	13	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.496239+02	wanangwa@gmail.com	\N	\N
215	10	15	44	52	11	5	4	bacteriology	8	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.497245+02	wanangwa@gmail.com	\N	\N
216	10	16	45	52	11	5	4	bacteriology	3	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.497245+02	wanangwa@gmail.com	\N	\N
217	10	14	42	47	10	5	4	bacteriology	18	gram_morphology	Bacterial Morphology	\N	Diplococci	\N	Diplococci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.498241+02	wanangwa@gmail.com	\N	\N
218	10	15	43	47	10	5	4	bacteriology	13	gram_morphology	Bacterial Morphology	\N	Diplococci	\N	Diplococci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.498241+02	wanangwa@gmail.com	\N	\N
219	10	15	44	52	11	5	4	bacteriology	8	gram_morphology	Bacterial Morphology	\N	Diplococci	\N	Diplococci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.499748+02	wanangwa@gmail.com	\N	\N
220	10	16	45	52	11	5	4	bacteriology	3	gram_morphology	Bacterial Morphology	\N	Diplococci	\N	Diplococci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.500758+02	wanangwa@gmail.com	\N	\N
221	10	14	42	47	10	5	4	bacteriology	18	organism_identified	Bacterial Identification	\N	Streptococcus agalactiae	\N	Streptococcus agalactiae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.500758+02	wanangwa@gmail.com	\N	\N
222	10	15	43	47	10	5	4	bacteriology	13	organism_identified	Bacterial Identification	\N	Streptococcus agalactiae	\N	Streptococcus agalactiae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.501763+02	wanangwa@gmail.com	\N	\N
223	10	15	44	52	11	5	4	bacteriology	8	organism_identified	Bacterial Identification	\N	Streptococcus agalactiae	\N	Streptococcus agalactiae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.502762+02	wanangwa@gmail.com	\N	\N
224	10	16	45	52	11	5	4	bacteriology	3	organism_identified	Bacterial Identification	\N	Streptococcus agalactiae	\N	Streptococcus agalactiae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.503763+02	wanangwa@gmail.com	\N	\N
225	10	14	42	47	10	5	4	bacteriology	18	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.503763+02	wanangwa@gmail.com	\N	\N
226	10	15	43	47	10	5	4	bacteriology	13	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.505265+02	wanangwa@gmail.com	\N	\N
227	10	15	44	52	11	5	4	bacteriology	8	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.506274+02	wanangwa@gmail.com	\N	\N
228	10	16	45	52	11	5	4	bacteriology	3	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.506274+02	wanangwa@gmail.com	\N	\N
229	10	14	42	46	10	5	4	bacteriology	17	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.507785+02	wanangwa@gmail.com	\N	\N
230	10	15	43	46	10	5	4	bacteriology	12	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.507785+02	wanangwa@gmail.com	\N	\N
231	10	15	44	51	11	5	4	bacteriology	7	gram_stain_reaction	Gram Stain Reaction	\N	Gram positive	\N	Gram positive	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.509805+02	wanangwa@gmail.com	\N	\N
232	10	16	45	51	11	5	4	bacteriology	2	gram_stain_reaction	Gram Stain Reaction	\N	\N	\N	Gram positive	\N	\N	\N	\N	0	3	Not Evaluated	f	Swab arrived dry, transport medium had leaked	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.511805+02	wanangwa@gmail.com	\N	\N
233	10	14	42	46	10	5	4	bacteriology	17	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.512804+02	wanangwa@gmail.com	\N	\N
234	10	15	43	46	10	5	4	bacteriology	12	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.513805+02	wanangwa@gmail.com	\N	\N
235	10	15	44	51	11	5	4	bacteriology	7	gram_morphology	Bacterial Morphology	\N	Cocci	\N	Cocci	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.514805+02	wanangwa@gmail.com	\N	\N
236	10	16	45	51	11	5	4	bacteriology	2	gram_morphology	Bacterial Morphology	\N	\N	\N	Cocci	\N	\N	\N	\N	0	3	Not Evaluated	f	Swab arrived dry, transport medium had leaked	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.514805+02	wanangwa@gmail.com	\N	\N
237	10	14	42	46	10	5	4	bacteriology	17	organism_identified	Bacterial Identification	\N	Staphylococcus epidermidis	\N	Staphylococcus epidermidis	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.515804+02	wanangwa@gmail.com	\N	\N
238	10	15	43	46	10	5	4	bacteriology	12	organism_identified	Bacterial Identification	\N	Staphylococcus aureus	\N	Staphylococcus epidermidis	\N	\N	\N	\N	0	10	Unacceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.517808+02	wanangwa@gmail.com	\N	\N
239	10	15	44	51	11	5	4	bacteriology	7	organism_identified	Bacterial Identification	\N	Staphylococcus epidermidis	\N	Staphylococcus epidermidis	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.517808+02	wanangwa@gmail.com	\N	\N
240	10	16	45	51	11	5	4	bacteriology	2	organism_identified	Bacterial Identification	\N	\N	\N	Staphylococcus epidermidis	\N	\N	\N	\N	0	10	Not Evaluated	f	Swab arrived dry, transport medium had leaked	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.518808+02	wanangwa@gmail.com	\N	\N
241	10	14	42	46	10	5	4	bacteriology	17	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.519807+02	wanangwa@gmail.com	\N	\N
242	10	15	43	46	10	5	4	bacteriology	12	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.519807+02	wanangwa@gmail.com	\N	\N
243	10	15	44	51	11	5	4	bacteriology	7	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.520807+02	wanangwa@gmail.com	\N	\N
244	10	16	45	51	11	5	4	bacteriology	2	ast_result	AST Results	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	Swab arrived dry, transport medium had leaked	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.521807+02	wanangwa@gmail.com	\N	\N
245	10	14	42	49	10	5	4	bacteriology	20	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.521807+02	wanangwa@gmail.com	\N	\N
246	10	16	45	54	11	5	4	bacteriology	5	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.522808+02	wanangwa@gmail.com	\N	\N
247	10	15	43	49	10	5	4	bacteriology	15	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.522808+02	wanangwa@gmail.com	\N	\N
248	10	15	44	54	11	5	4	bacteriology	10	gram_stain_reaction	Gram Stain Reaction	\N	Gram negative	\N	Gram negative	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.524314+02	wanangwa@gmail.com	\N	\N
249	10	14	42	49	10	5	4	bacteriology	20	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.524314+02	wanangwa@gmail.com	\N	\N
250	10	16	45	54	11	5	4	bacteriology	5	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.524314+02	wanangwa@gmail.com	\N	\N
251	10	15	43	49	10	5	4	bacteriology	15	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.52584+02	wanangwa@gmail.com	\N	\N
252	10	15	44	54	11	5	4	bacteriology	10	gram_morphology	Bacterial Morphology	\N	Bacilli	\N	Bacilli	\N	\N	\N	\N	3	3	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.526853+02	wanangwa@gmail.com	\N	\N
253	10	14	42	49	10	5	4	bacteriology	20	organism_identified	Bacterial Identification	\N	Klebsiella pneumoniae	\N	Klebsiella pneumoniae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.527848+02	wanangwa@gmail.com	\N	\N
254	10	16	45	54	11	5	4	bacteriology	5	organism_identified	Bacterial Identification	\N	Klebsiella pneumoniae	\N	Klebsiella pneumoniae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.528848+02	wanangwa@gmail.com	\N	\N
255	10	15	43	49	10	5	4	bacteriology	15	organism_identified	Bacterial Identification	\N	Klebsiella pneumoniae	\N	Klebsiella pneumoniae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.529358+02	wanangwa@gmail.com	\N	\N
256	10	15	44	54	11	5	4	bacteriology	10	organism_identified	Bacterial Identification	\N	Klebsiella pneumoniae	\N	Klebsiella pneumoniae	\N	\N	\N	\N	10	10	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.529358+02	wanangwa@gmail.com	\N	\N
257	10	14	42	49	10	5	4	bacteriology	20	ast_result	AST Results	\N	AMIKACIN:S|CEFTRIAXONE:S|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	\N	\N	\N	0	20	Unacceptable	t	Disagreed on CEFTRIAXONE	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.530365+02	wanangwa@gmail.com	\N	\N
258	10	16	45	54	11	5	4	bacteriology	5	ast_result	AST Results	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.531365+02	wanangwa@gmail.com	\N	\N
259	10	15	43	49	10	5	4	bacteriology	15	ast_result	AST Results	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.531365+02	wanangwa@gmail.com	\N	\N
260	10	15	44	54	11	5	4	bacteriology	10	ast_result	AST Results	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	\N	\N	\N	\N	20	20	Acceptable	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.532875+02	wanangwa@gmail.com	\N	\N
261	5	1	24	27	7	3	2	hiv_vl	17	viral_load_log10	Viral Load (log10 copies/ml)	2.52	\N	2.52	\N	2.568	0.1779	0	0	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.879792+02	wanangwa@gmail.com	\N	\N
262	5	10	26	22	6	3	2	hiv_vl	7	viral_load_log10	Viral Load (log10 copies/ml)	2.44	\N	2.52	\N	2.568	0.1779	-0.08	-0.4497	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.890057+02	wanangwa@gmail.com	\N	\N
263	5	11	28	27	7	3	2	hiv_vl	22	viral_load_log10	Viral Load (log10 copies/ml)	2.44	\N	2.52	\N	2.568	0.1779	-0.08	-0.4497	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.891072+02	wanangwa@gmail.com	\N	\N
264	5	9	25	17	5	3	2	hiv_vl	12	viral_load_log10	Viral Load (log10 copies/ml)	2.76	\N	2.52	\N	2.568	0.1779	0.24	1.3491	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.893069+02	wanangwa@gmail.com	\N	\N
265	5	11	27	17	5	3	2	hiv_vl	2	viral_load_log10	Viral Load (log10 copies/ml)	2.68	\N	2.52	\N	2.568	0.1779	0.16	0.8994	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.894074+02	wanangwa@gmail.com	\N	\N
266	5	1	24	26	7	3	2	hiv_vl	16	viral_load_log10	Viral Load (log10 copies/ml)	0	\N	0	\N	0	0	\N	\N	0	0	Not Evaluated	f	The participants showed no measurable spread, so a z-score cannot be calculated	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.895072+02	wanangwa@gmail.com	\N	\N
267	5	9	25	16	5	3	2	hiv_vl	11	viral_load_log10	Viral Load (log10 copies/ml)	0	\N	0	\N	0	0	\N	\N	0	0	Not Evaluated	f	The participants showed no measurable spread, so a z-score cannot be calculated	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.897598+02	wanangwa@gmail.com	\N	\N
268	5	11	27	16	5	3	2	hiv_vl	1	viral_load_log10	Viral Load (log10 copies/ml)	0	\N	0	\N	0	0	\N	\N	0	0	Not Evaluated	f	The participants showed no measurable spread, so a z-score cannot be calculated	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.898592+02	wanangwa@gmail.com	\N	\N
269	5	10	26	21	6	3	2	hiv_vl	6	viral_load_log10	Viral Load (log10 copies/ml)	0	\N	0	\N	0	0	\N	\N	0	0	Not Evaluated	f	The participants showed no measurable spread, so a z-score cannot be calculated	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.898592+02	wanangwa@gmail.com	\N	\N
270	5	11	28	26	7	3	2	hiv_vl	21	viral_load_log10	Viral Load (log10 copies/ml)	0	\N	0	\N	0	0	\N	\N	0	0	Not Evaluated	f	The participants showed no measurable spread, so a z-score cannot be calculated	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.899592+02	wanangwa@gmail.com	\N	\N
271	5	1	24	28	7	3	2	hiv_vl	18	viral_load_log10	Viral Load (log10 copies/ml)	5.58	\N	4.1	\N	4.564	0.8006	1.48	1.8486	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.900596+02	wanangwa@gmail.com	\N	\N
272	5	9	25	18	5	3	2	hiv_vl	13	viral_load_log10	Viral Load (log10 copies/ml)	3.86	\N	4.1	\N	4.564	0.8006	-0.24	-0.2998	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.90159+02	wanangwa@gmail.com	\N	\N
273	5	11	27	18	5	3	2	hiv_vl	3	viral_load_log10	Viral Load (log10 copies/ml)	5.18	\N	4.1	\N	4.564	0.8006	1.08	1.349	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.902591+02	wanangwa@gmail.com	\N	\N
274	5	10	26	23	6	3	2	hiv_vl	8	viral_load_log10	Viral Load (log10 copies/ml)	4.1	\N	4.1	\N	4.564	0.8006	0	0	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.903594+02	wanangwa@gmail.com	\N	\N
275	5	11	28	28	7	3	2	hiv_vl	23	viral_load_log10	Viral Load (log10 copies/ml)	4.1	\N	4.1	\N	4.564	0.8006	0	0	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.903594+02	wanangwa@gmail.com	\N	\N
276	5	1	24	29	7	3	2	hiv_vl	19	viral_load_log10	Viral Load (log10 copies/ml)	5.29	\N	5.21	\N	5.226	0.0593	0.08	1.3491	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.904591+02	wanangwa@gmail.com	\N	\N
277	5	10	26	24	6	3	2	hiv_vl	9	viral_load_log10	Viral Load (log10 copies/ml)	5.21	\N	5.21	\N	5.226	0.0593	0	0	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.904591+02	wanangwa@gmail.com	\N	\N
278	5	11	28	29	7	3	2	hiv_vl	24	viral_load_log10	Viral Load (log10 copies/ml)	5.21	\N	5.21	\N	5.226	0.0593	0	0	2	2	Acceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.906047+02	wanangwa@gmail.com	\N	\N
279	5	9	25	19	5	3	2	hiv_vl	14	viral_load_log10	Viral Load (log10 copies/ml)	4.97	\N	5.21	\N	5.226	0.0593	-0.24	-4.0472	0	2	Unacceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.907055+02	wanangwa@gmail.com	\N	\N
280	5	11	27	19	5	3	2	hiv_vl	4	viral_load_log10	Viral Load (log10 copies/ml)	5.45	\N	5.21	\N	5.226	0.0593	0.24	4.0472	0	2	Unacceptable	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.907055+02	wanangwa@gmail.com	\N	\N
281	5	1	24	30	7	3	2	hiv_vl	20	viral_load_log10	Viral Load (log10 copies/ml)	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	Panel arrived thawed, sample integrity compromised	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.908066+02	wanangwa@gmail.com	\N	\N
282	5	9	25	20	5	3	2	hiv_vl	15	viral_load_log10	Viral Load (log10 copies/ml)	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	Panel arrived thawed, sample integrity compromised	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.909064+02	wanangwa@gmail.com	\N	\N
283	5	11	27	20	5	3	2	hiv_vl	5	viral_load_log10	Viral Load (log10 copies/ml)	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	Panel arrived thawed, sample integrity compromised	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.909064+02	wanangwa@gmail.com	\N	\N
284	5	10	26	25	6	3	2	hiv_vl	10	viral_load_log10	Viral Load (log10 copies/ml)	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	Panel arrived thawed, sample integrity compromised	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.910798+02	wanangwa@gmail.com	\N	\N
285	5	11	28	30	7	3	2	hiv_vl	25	viral_load_log10	Viral Load (log10 copies/ml)	\N	\N	\N	\N	\N	\N	\N	\N	0	0	Not Evaluated	f	Panel arrived thawed, sample integrity compromised	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.910798+02	wanangwa@gmail.com	\N	\N
\.


--
-- Data for Name: pt_sample_statistics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pt_sample_statistics (id, pt_cycle_id, method_sample_id, method_id, service_id, scheme_id, result_form, attribute, attribute_label, evaluation_kind, assigned_value_numeric, assigned_value_text, assigned_value_source, participant_count, reported_count, group_mean, group_median, robust_sd, standard_sd, minimum_value, maximum_value, concordant_count, evaluated, not_evaluated_reason, frozen_at, frozen_by, created_at, created_by, updated_at, updated_by, sample_group) FROM stdin;
1	1	1	1	2	1	tb_xpert_ultra	tb_detection_result	TB Detection Result	qualitative	\N	NOT DETECTED	predefined	6	6	\N	\N	\N	\N	\N	\N	6	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.930108+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-1
2	1	1	1	2	1	tb_xpert_ultra	rif_result	Rif Result	qualitative	\N	N/A	predefined	6	6	\N	\N	\N	\N	\N	\N	6	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.933108+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-1
3	1	2	1	2	1	tb_xpert_ultra	tb_detection_result	TB Detection Result	qualitative	\N	HIGH	predefined	6	6	\N	\N	\N	\N	\N	\N	5	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.935108+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-2
4	1	2	1	2	1	tb_xpert_ultra	rif_result	Rif Result	qualitative	\N	NOT DETECTED	predefined	6	6	\N	\N	\N	\N	\N	\N	6	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.936108+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-2
5	1	4	1	2	1	tb_xpert_ultra	tb_detection_result	TB Detection Result	qualitative	\N	TRACE	predefined	6	6	\N	\N	\N	\N	\N	\N	5	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.936108+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-4
6	1	4	1	2	1	tb_xpert_ultra	rif_result	Rif Result	qualitative	\N	N/A	predefined	6	6	\N	\N	\N	\N	\N	\N	6	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.937109+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-4
7	1	5	1	2	1	tb_xpert_ultra	tb_detection_result	TB Detection Result	qualitative	\N	LOW	predefined	6	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.939108+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-5
8	1	5	1	2	1	tb_xpert_ultra	rif_result	Rif Result	qualitative	\N	NOT DETECTED	predefined	6	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.940614+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-5
9	1	3	1	2	1	tb_xpert_ultra	tb_detection_result	TB Detection Result	qualitative	\N	MEDIUM	predefined	6	6	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.940614+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-3
10	1	3	1	2	1	tb_xpert_ultra	rif_result	Rif Result	qualitative	\N	DETECTED	predefined	6	6	\N	\N	\N	\N	\N	\N	6	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.941624+02	wanangwa@gmail.com	\N	\N	ultra-CDL-2026-A-3
11	1	8	2	2	1	tb_xpert_xdr	tb_detection_result	TB Detection Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.941624+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-3
12	1	8	2	2	1	tb_xpert_xdr	inh_result	INH Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	1	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.943132+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-3
13	1	8	2	2	1	tb_xpert_xdr	flq_result	FLQ Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.944147+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-3
14	1	8	2	2	1	tb_xpert_xdr	amk_result	AMK Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.944147+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-3
15	1	8	2	2	1	tb_xpert_xdr	eth_result	ETH Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.945144+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-3
16	1	6	2	2	1	tb_xpert_xdr	tb_detection_result	TB Detection Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.946147+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-1
17	1	6	2	2	1	tb_xpert_xdr	inh_result	INH Result	qualitative	\N	N/A	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.947145+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-1
18	1	6	2	2	1	tb_xpert_xdr	flq_result	FLQ Result	qualitative	\N	N/A	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.947145+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-1
19	1	6	2	2	1	tb_xpert_xdr	amk_result	AMK Result	qualitative	\N	N/A	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.948139+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-1
20	1	6	2	2	1	tb_xpert_xdr	eth_result	ETH Result	qualitative	\N	N/A	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.948139+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-1
21	1	10	2	2	1	tb_xpert_xdr	tb_detection_result	TB Detection Result	qualitative	\N	DETECTED	predefined	3	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.949142+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-5
22	1	10	2	2	1	tb_xpert_xdr	inh_result	INH Result	qualitative	\N	NOT DETECTED	predefined	3	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.950143+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-5
23	1	10	2	2	1	tb_xpert_xdr	flq_result	FLQ Result	qualitative	\N	NOT DETECTED	predefined	3	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.950143+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-5
24	1	10	2	2	1	tb_xpert_xdr	amk_result	AMK Result	qualitative	\N	DETECTED	predefined	3	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.951144+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-5
25	1	10	2	2	1	tb_xpert_xdr	eth_result	ETH Result	qualitative	\N	NOT DETECTED	predefined	3	0	\N	\N	\N	\N	\N	\N	0	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.951144+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-5
26	1	7	2	2	1	tb_xpert_xdr	tb_detection_result	TB Detection Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.952144+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-2
27	1	7	2	2	1	tb_xpert_xdr	inh_result	INH Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.952144+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-2
28	1	7	2	2	1	tb_xpert_xdr	flq_result	FLQ Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.953143+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-2
29	1	7	2	2	1	tb_xpert_xdr	amk_result	AMK Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.953143+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-2
30	1	7	2	2	1	tb_xpert_xdr	eth_result	ETH Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.954142+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-2
31	1	9	2	2	1	tb_xpert_xdr	tb_detection_result	TB Detection Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.954142+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-4
32	1	9	2	2	1	tb_xpert_xdr	inh_result	INH Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	2	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.955153+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-4
33	1	9	2	2	1	tb_xpert_xdr	flq_result	FLQ Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.955153+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-4
34	1	9	2	2	1	tb_xpert_xdr	amk_result	AMK Result	qualitative	\N	NOT DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.95715+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-4
35	1	9	2	2	1	tb_xpert_xdr	eth_result	ETH Result	qualitative	\N	DETECTED	predefined	3	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:45.735922+02	wanangwa@gmail.com	2026-09-18 11:43:45.95815+02	wanangwa@gmail.com	\N	\N	xdr-CDL-2026-A-4
41	7	40	9	4	3	hiv_eid	hiv_result	Your Result	qualitative	\N	HIV-1 Detected	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.814218+02	wanangwa@gmail.com	\N	\N	2026-01
42	7	42	9	4	3	hiv_eid	hiv_result	Your Result	qualitative	\N	HIV-1 Not Detected	predefined	4	3	\N	\N	\N	\N	\N	\N	2	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.815218+02	wanangwa@gmail.com	\N	\N	2026-03
43	7	44	9	4	3	hiv_eid	hiv_result	Your Result	qualitative	\N	HIV-1 Detected	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.815218+02	wanangwa@gmail.com	\N	\N	2026-05
44	7	34	8	4	3	hiv_eid	hiv_result	Your Result	qualitative	\N	HIV-1 Not Detected	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.816218+02	wanangwa@gmail.com	\N	\N	2026-02
45	7	36	8	4	3	hiv_eid	hiv_result	Your Result	qualitative	\N	HIV-1 Not Detected	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:49.687196+02	wanangwa@gmail.com	2026-09-18 11:43:49.816218+02	wanangwa@gmail.com	\N	\N	2026-04
46	10	48	10	5	4	bacteriology	gram_stain_reaction	Gram Stain Reaction	qualitative	\N	Gram positive	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.533886+02	wanangwa@gmail.com	\N	\N	NHRTIBACT D01-26
47	10	48	10	5	4	bacteriology	gram_morphology	Bacterial Morphology	qualitative	\N	Cocci	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.535399+02	wanangwa@gmail.com	\N	\N	NHRTIBACT D01-26
48	10	48	10	5	4	bacteriology	organism_identified	Bacterial Identification	qualitative	\N	Staphylococcus aureus	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.535399+02	wanangwa@gmail.com	\N	\N	NHRTIBACT D01-26
49	10	48	10	5	4	bacteriology	ast_result	AST Results	qualitative	\N	\N	\N	4	4	\N	\N	\N	\N	\N	\N	\N	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.536421+02	wanangwa@gmail.com	\N	\N	NHRTIBACT D01-26
50	10	45	10	5	4	bacteriology	gram_stain_reaction	Gram Stain Reaction	qualitative	\N	Gram negative	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.536421+02	wanangwa@gmail.com	\N	\N	NHRTIBACT A01-26
51	10	45	10	5	4	bacteriology	gram_morphology	Bacterial Morphology	qualitative	\N	Bacilli	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.537414+02	wanangwa@gmail.com	\N	\N	NHRTIBACT A01-26
52	10	45	10	5	4	bacteriology	organism_identified	Bacterial Identification	qualitative	\N	Escherichia coli	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.540411+02	wanangwa@gmail.com	\N	\N	NHRTIBACT A01-26
53	10	45	10	5	4	bacteriology	ast_result	AST Results	qualitative	\N	\N	\N	4	4	\N	\N	\N	\N	\N	\N	\N	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.540411+02	wanangwa@gmail.com	\N	\N	NHRTIBACT A01-26
54	10	47	10	5	4	bacteriology	gram_stain_reaction	Gram Stain Reaction	qualitative	\N	Gram positive	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.541412+02	wanangwa@gmail.com	\N	\N	NHRTIBACT C01-26
55	10	47	10	5	4	bacteriology	gram_morphology	Bacterial Morphology	qualitative	\N	Diplococci	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.542412+02	wanangwa@gmail.com	\N	\N	NHRTIBACT C01-26
56	10	47	10	5	4	bacteriology	organism_identified	Bacterial Identification	qualitative	\N	Streptococcus agalactiae	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.543424+02	wanangwa@gmail.com	\N	\N	NHRTIBACT C01-26
57	10	47	10	5	4	bacteriology	ast_result	AST Results	qualitative	\N	\N	\N	4	4	\N	\N	\N	\N	\N	\N	\N	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.543424+02	wanangwa@gmail.com	\N	\N	NHRTIBACT C01-26
58	10	46	10	5	4	bacteriology	gram_stain_reaction	Gram Stain Reaction	qualitative	\N	Gram positive	predefined	4	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.545426+02	wanangwa@gmail.com	\N	\N	NHRTIBACT B01-26
59	10	46	10	5	4	bacteriology	gram_morphology	Bacterial Morphology	qualitative	\N	Cocci	predefined	4	3	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.54642+02	wanangwa@gmail.com	\N	\N	NHRTIBACT B01-26
60	10	46	10	5	4	bacteriology	organism_identified	Bacterial Identification	qualitative	\N	Staphylococcus epidermidis	predefined	4	3	\N	\N	\N	\N	\N	\N	2	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.54642+02	wanangwa@gmail.com	\N	\N	NHRTIBACT B01-26
61	10	46	10	5	4	bacteriology	ast_result	AST Results	qualitative	\N	\N	\N	4	3	\N	\N	\N	\N	\N	\N	\N	f	No stated value for this panel of antibiotics, so the AST section could not be graded	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.547422+02	wanangwa@gmail.com	\N	\N	NHRTIBACT B01-26
62	10	49	10	5	4	bacteriology	gram_stain_reaction	Gram Stain Reaction	qualitative	\N	Gram negative	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.548426+02	wanangwa@gmail.com	\N	\N	NHRTIBACT E01-26
63	10	49	10	5	4	bacteriology	gram_morphology	Bacterial Morphology	qualitative	\N	Bacilli	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.548426+02	wanangwa@gmail.com	\N	\N	NHRTIBACT E01-26
64	10	49	10	5	4	bacteriology	organism_identified	Bacterial Identification	qualitative	\N	Klebsiella pneumoniae	predefined	4	4	\N	\N	\N	\N	\N	\N	4	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.549424+02	wanangwa@gmail.com	\N	\N	NHRTIBACT E01-26
65	10	49	10	5	4	bacteriology	ast_result	AST Results	qualitative	\N	AMIKACIN:S|CEFTRIAXONE:R|CIPROFLOXACIN:S|GENTAMICIN:S|MEROPENEM:S	predefined	4	4	\N	\N	\N	\N	\N	\N	3	t	\N	2026-09-18 11:43:51.44535+02	wanangwa@gmail.com	2026-09-18 11:43:51.550426+02	wanangwa@gmail.com	\N	\N	NHRTIBACT E01-26
66	5	27	7	3	2	hiv_vl	viral_load_log10	Viral Load (log10 copies/ml)	quantitative	2.52	\N	consensus	5	5	2.568	2.52	0.1779	0.1453	2.44	2.76	\N	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.912807+02	wanangwa@gmail.com	\N	\N	VL 2026-A2
67	5	26	7	3	2	hiv_vl	viral_load_log10	Viral Load (log10 copies/ml)	quantitative	0	\N	consensus	5	5	0	0	0	0	0	0	\N	f	The participants showed no measurable spread, so a z-score cannot be calculated	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.921326+02	wanangwa@gmail.com	\N	\N	VL 2026-A1
68	5	28	7	3	2	hiv_vl	viral_load_log10	Viral Load (log10 copies/ml)	quantitative	4.1	\N	consensus	5	5	4.564	4.1	0.8006	0.7645	3.86	5.58	\N	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.923771+02	wanangwa@gmail.com	\N	\N	VL 2026-A3
69	5	29	7	3	2	hiv_vl	viral_load_log10	Viral Load (log10 copies/ml)	quantitative	5.21	\N	consensus	5	5	5.226	5.21	0.0593	0.1734	4.97	5.45	\N	t	\N	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.924769+02	wanangwa@gmail.com	\N	\N	VL 2026-A4
70	5	30	7	3	2	hiv_vl	viral_load_log10	Viral Load (log10 copies/ml)	quantitative	\N	\N	\N	5	0	\N	\N	\N	\N	\N	\N	\N	f	Fewer than 3 participants reported a result, so no consensus value could be assigned	2026-09-18 11:44:23.855959+02	wanangwa@gmail.com	2026-09-18 11:44:23.926278+02	wanangwa@gmail.com	\N	\N	VL 2026-A5
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Administrator	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.548572+02	\N	\N	\N
2	Scheme Head	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.554389+02	\N	\N	\N
3	Scheme Coordinator	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.558354+02	\N	\N	\N
4	Scheme Quality Officers	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.560383+02	\N	\N	\N
5	Finance Officers	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.563896+02	\N	\N	\N
6	Provincial Biomedical Scientists (PBs)	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.565803+02	\N	\N	\N
7	EQA/QMS Focal Point Persons (FPPs)	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.570203+02	\N	\N	\N
8	District Laboratory Coordinators 	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.572715+02	\N	\N	\N
9	Facility Super User	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.576227+02	\N	\N	\N
10	Facility Staff	\N	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:37:25.578746+02	\N	\N	\N
\.


--
-- Data for Name: schemes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schemes (id, name, description, provider_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	Tuberculosis (TB)	TB proficiency testing scheme	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:46:25.836985+02	\N	2026-09-14 20:23:25.639662+02	\N
2	HIV-1 Viral Load- Conventional PCR	HIV-1 viral load proficiency testing by conventional PCR	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:20:54.491691+02	\N	2026-09-14 22:38:24.662469+02	\N
3	HIV EID-Conventional PCR	HIV-1 early infant diagnosis by conventional PCR	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:21:07.541669+02	\N	2026-09-14 23:41:44.907679+02	\N
4	Bacteriology	NHRTI-Bacteriology proficiency testing scheme	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.910609+02	\N	\N	\N
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, name, description, scheme_id, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
1	TB Microscopy	Sputum smear microscopy	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 07:52:44.223225+02	\N	2026-09-14 20:23:25.650464+02	\N
2	TB Xpert	GeneXpert molecular testing	1	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-23 13:47:07.879945+02	\N	2026-09-14 20:23:25.65349+02	\N
3	HIV-1 Viral Load	Quantitative HIV-1 RNA testing	2	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 22:38:24.665489+02	\N	\N	\N
4	Early Infant Diagnosis	Qualitative HIV-1 DNA/RNA detection in infants	3	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 23:41:44.911707+02	\N	\N	\N
5	Bacteriology (MCS)	Microscopy, Culture and Sensitivity Testing	4	1	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 09:37:49.919484+02	\N	\N	\N
\.


--
-- Data for Name: tb_xpert_ultra_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_xpert_ultra_results (id, name, description, scheme_id, lab_id, service_id, pt_cycle_id, method_id, enrollment_id, method_sample_id, result_interpretable, tb_detection_result, rif_result, uninterpretable_result, ultra_spc, is1081_is6110, rpob1, rpob2, rpob3, rpob4, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, xpert_module_number, date_tested, error_code) FROM stdin;
26	ultra-CDL-2026-A-1 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample ultra-CDL-2026-A-1 for Levy Mwanawasa University Teaching Hospital	1	1	2	1	1	1	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	255	4	5	1	2026-09-18 11:43:44.619305+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.174936+02	wanangwa@gmail.com	2026-09-18 11:43:44.620303+02	quality@cdl.moh.gov.zm	A1	2026-05-27	\N
27	ultra-CDL-2026-A-2 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample ultra-CDL-2026-A-2 for Levy Mwanawasa University Teaching Hospital	1	1	2	1	1	1	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	255	4	5	1	2026-09-18 11:43:44.638258+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.174936+02	wanangwa@gmail.com	2026-09-18 11:43:44.63977+02	quality@cdl.moh.gov.zm	A2	2026-05-27	\N
29	ultra-CDL-2026-A-4 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample ultra-CDL-2026-A-4 for Levy Mwanawasa University Teaching Hospital	1	1	2	1	1	1	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	255	4	5	1	2026-09-18 11:43:44.68147+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.175674+02	wanangwa@gmail.com	2026-09-18 11:43:44.681977+02	quality@cdl.moh.gov.zm	A4	2026-05-27	\N
30	ultra-CDL-2026-A-5 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample ultra-CDL-2026-A-5 for Levy Mwanawasa University Teaching Hospital	1	1	2	1	1	1	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	255	4	5	1	2026-09-18 11:43:44.696602+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.17668+02	wanangwa@gmail.com	2026-09-18 11:43:44.696602+02	quality@cdl.moh.gov.zm	A1	2026-05-27	5007
22	ultra-CDL-2026-A-2 - Levy Lusaka Laboratory	DTS Round One 2026 panel sample ultra-CDL-2026-A-2 for Levy Lusaka Laboratory	1	2	2	1	1	3	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	256	4	5	1	2026-09-18 11:43:44.727697+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.173118+02	wanangwa@gmail.com	2026-09-18 11:43:44.728704+02	quality@cdl.moh.gov.zm	A2	2026-05-27	\N
24	ultra-CDL-2026-A-4 - Levy Lusaka Laboratory	DTS Round One 2026 panel sample ultra-CDL-2026-A-4 for Levy Lusaka Laboratory	1	2	2	1	1	3	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	256	4	5	1	2026-09-18 11:43:44.757124+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.17363+02	wanangwa@gmail.com	2026-09-18 11:43:44.75863+02	quality@cdl.moh.gov.zm	A4	2026-05-27	\N
25	ultra-CDL-2026-A-5 - Levy Lusaka Laboratory	DTS Round One 2026 panel sample ultra-CDL-2026-A-5 for Levy Lusaka Laboratory	1	2	2	1	1	3	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	256	4	5	1	2026-09-18 11:43:44.775472+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.174368+02	wanangwa@gmail.com	2026-09-18 11:43:44.775472+02	quality@cdl.moh.gov.zm	A1	2026-05-27	5007
17	ultra-CDL-2026-A-2 - Private Lab 1	DTS Round One 2026 panel sample ultra-CDL-2026-A-2 for Private Lab 1	1	3	2	1	1	5	2	Yes	MEDIUM	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	257	4	5	1	2026-09-18 11:43:44.808217+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.170495+02	wanangwa@gmail.com	2026-09-18 11:43:44.809217+02	quality@cdl.moh.gov.zm	A2	2026-05-27	\N
19	ultra-CDL-2026-A-4 - Private Lab 1	DTS Round One 2026 panel sample ultra-CDL-2026-A-4 for Private Lab 1	1	3	2	1	1	5	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	257	4	5	1	2026-09-18 11:43:44.84255+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.172088+02	wanangwa@gmail.com	2026-09-18 11:43:44.843549+02	quality@cdl.moh.gov.zm	A4	2026-05-27	\N
20	ultra-CDL-2026-A-5 - Private Lab 1	DTS Round One 2026 panel sample ultra-CDL-2026-A-5 for Private Lab 1	1	3	2	1	1	5	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	257	4	5	1	2026-09-18 11:43:44.858007+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.172088+02	wanangwa@gmail.com	2026-09-18 11:43:44.859006+02	quality@cdl.moh.gov.zm	A1	2026-05-27	5007
12	ultra-CDL-2026-A-2 - UTH New Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-2 for UTH New Lab	1	4	2	1	1	6	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	258	4	5	1	2026-09-18 11:43:44.897752+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.168094+02	wanangwa@gmail.com	2026-09-18 11:43:44.897752+02	quality@cdl.moh.gov.zm	A2	2026-05-27	\N
14	ultra-CDL-2026-A-4 - UTH New Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-4 for UTH New Lab	1	4	2	1	1	6	4	Yes	NOT DETECTED	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	258	4	5	1	2026-09-18 11:43:44.932094+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.169124+02	wanangwa@gmail.com	2026-09-18 11:43:44.932094+02	quality@cdl.moh.gov.zm	A4	2026-05-27	\N
6	ultra-CDL-2026-A-1 - Ndola Teaching Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-1 for Ndola Teaching Hospital Lab	1	5	2	1	1	8	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	259	4	5	1	2026-09-18 11:43:44.999161+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.164716+02	wanangwa@gmail.com	2026-09-18 11:43:44.999161+02	quality@cdl.moh.gov.zm	A1	2026-05-27	\N
8	ultra-CDL-2026-A-3 - Ndola Teaching Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-3 for Ndola Teaching Hospital Lab	1	5	2	1	1	8	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	259	4	5	1	2026-09-18 11:43:45.098796+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.165769+02	wanangwa@gmail.com	2026-09-18 11:43:45.099796+02	quality@cdl.moh.gov.zm	A3	2026-05-27	\N
10	ultra-CDL-2026-A-5 - Ndola Teaching Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-5 for Ndola Teaching Hospital Lab	1	5	2	1	1	8	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	259	4	5	1	2026-09-18 11:43:45.180219+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.166832+02	wanangwa@gmail.com	2026-09-18 11:43:45.180219+02	quality@cdl.moh.gov.zm	A1	2026-05-27	5007
1	ultra-CDL-2026-A-1 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-1 for Kitwe Central Hospital Lab	1	6	2	1	1	9	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	260	4	5	1	2026-09-18 11:43:45.207212+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.158873+02	wanangwa@gmail.com	2026-09-18 11:43:45.207212+02	quality@cdl.moh.gov.zm	A1	2026-05-27	\N
3	ultra-CDL-2026-A-3 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-3 for Kitwe Central Hospital Lab	1	6	2	1	1	9	3	Yes	LOW	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	260	4	5	1	2026-09-18 11:43:45.250738+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.162205+02	wanangwa@gmail.com	2026-09-18 11:43:45.251737+02	quality@cdl.moh.gov.zm	A3	2026-05-27	\N
5	ultra-CDL-2026-A-5 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-5 for Kitwe Central Hospital Lab	1	6	2	1	1	9	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	260	4	5	1	2026-09-18 11:43:45.298885+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.163717+02	wanangwa@gmail.com	2026-09-18 11:43:45.29989+02	quality@cdl.moh.gov.zm	A1	2026-05-27	5007
44	ultra-CDL-2026-A-4 - Private Lab 1	DTS Round Two 2026 panel sample ultra-CDL-2026-A-4 for Private Lab 1	1	3	2	2	1	15	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	257	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.184732+02	wanangwa@gmail.com	2026-09-18 11:43:46.604492+02	markdoe@gmail.com	A4	2026-09-13	\N
28	ultra-CDL-2026-A-3 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample ultra-CDL-2026-A-3 for Levy Mwanawasa University Teaching Hospital	1	1	2	1	1	1	3	Yes	LOW	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	255	4	5	1	2026-09-18 11:43:44.660911+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.175674+02	wanangwa@gmail.com	2026-09-18 11:43:44.66191+02	quality@cdl.moh.gov.zm	A3	2026-05-27	\N
21	ultra-CDL-2026-A-1 - Levy Lusaka Laboratory	DTS Round One 2026 panel sample ultra-CDL-2026-A-1 for Levy Lusaka Laboratory	1	2	2	1	1	3	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	256	4	5	1	2026-09-18 11:43:44.711163+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.172594+02	wanangwa@gmail.com	2026-09-18 11:43:44.712435+02	quality@cdl.moh.gov.zm	A1	2026-05-27	\N
23	ultra-CDL-2026-A-3 - Levy Lusaka Laboratory	DTS Round One 2026 panel sample ultra-CDL-2026-A-3 for Levy Lusaka Laboratory	1	2	2	1	1	3	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	256	4	5	1	2026-09-18 11:43:44.742119+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.17363+02	wanangwa@gmail.com	2026-09-18 11:43:44.742119+02	quality@cdl.moh.gov.zm	A3	2026-05-27	\N
16	ultra-CDL-2026-A-1 - Private Lab 1	DTS Round One 2026 panel sample ultra-CDL-2026-A-1 for Private Lab 1	1	3	2	1	1	5	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	257	4	5	1	2026-09-18 11:43:44.792186+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.16999+02	wanangwa@gmail.com	2026-09-18 11:43:44.793187+02	quality@cdl.moh.gov.zm	A1	2026-05-27	\N
18	ultra-CDL-2026-A-3 - Private Lab 1	DTS Round One 2026 panel sample ultra-CDL-2026-A-3 for Private Lab 1	1	3	2	1	1	5	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	257	4	5	1	2026-09-18 11:43:44.824732+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.171007+02	wanangwa@gmail.com	2026-09-18 11:43:44.825732+02	quality@cdl.moh.gov.zm	A3	2026-05-27	\N
11	ultra-CDL-2026-A-1 - UTH New Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-1 for UTH New Lab	1	4	2	1	1	6	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	258	4	5	1	2026-09-18 11:43:44.876604+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.167497+02	wanangwa@gmail.com	2026-09-18 11:43:44.876604+02	quality@cdl.moh.gov.zm	A1	2026-05-27	\N
13	ultra-CDL-2026-A-3 - UTH New Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-3 for UTH New Lab	1	4	2	1	1	6	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	258	4	5	1	2026-09-18 11:43:44.912923+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.1686+02	wanangwa@gmail.com	2026-09-18 11:43:44.912923+02	quality@cdl.moh.gov.zm	A3	2026-05-27	\N
15	ultra-CDL-2026-A-5 - UTH New Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-5 for UTH New Lab	1	4	2	1	1	6	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	258	4	5	1	2026-09-18 11:43:44.965726+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.169643+02	wanangwa@gmail.com	2026-09-18 11:43:44.966235+02	quality@cdl.moh.gov.zm	A1	2026-05-27	5007
7	ultra-CDL-2026-A-2 - Ndola Teaching Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-2 for Ndola Teaching Hospital Lab	1	5	2	1	1	8	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	259	4	5	1	2026-09-18 11:43:45.046227+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.165437+02	wanangwa@gmail.com	2026-09-18 11:43:45.046227+02	quality@cdl.moh.gov.zm	A2	2026-05-27	\N
9	ultra-CDL-2026-A-4 - Ndola Teaching Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-4 for Ndola Teaching Hospital Lab	1	5	2	1	1	8	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	259	4	5	1	2026-09-18 11:43:45.144356+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.166276+02	wanangwa@gmail.com	2026-09-18 11:43:45.144876+02	quality@cdl.moh.gov.zm	A4	2026-05-27	\N
2	ultra-CDL-2026-A-2 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-2 for Kitwe Central Hospital Lab	1	6	2	1	1	9	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	260	4	5	1	2026-09-18 11:43:45.229218+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.161206+02	wanangwa@gmail.com	2026-09-18 11:43:45.229218+02	quality@cdl.moh.gov.zm	A2	2026-05-27	\N
4	ultra-CDL-2026-A-4 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample ultra-CDL-2026-A-4 for Kitwe Central Hospital Lab	1	6	2	1	1	9	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	260	4	5	1	2026-09-18 11:43:45.2768+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.16271+02	wanangwa@gmail.com	2026-09-18 11:43:45.2768+02	quality@cdl.moh.gov.zm	A4	2026-05-27	\N
41	ultra-CDL-2026-A-1 - Private Lab 1	DTS Round Two 2026 panel sample ultra-CDL-2026-A-1 for Private Lab 1	1	3	2	2	1	15	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	257	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.183225+02	wanangwa@gmail.com	2026-09-18 11:43:46.575602+02	markdoe@gmail.com	A1	2026-09-13	\N
36	ultra-CDL-2026-A-1 - UTH New Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-1 for UTH New Lab	1	4	2	2	1	16	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.182223+02	wanangwa@gmail.com	2026-09-18 11:43:46.621333+02	alanphiri@gmail.com	A1	2026-09-13	\N
37	ultra-CDL-2026-A-2 - UTH New Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-2 for UTH New Lab	1	4	2	2	1	16	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.182223+02	wanangwa@gmail.com	2026-09-18 11:43:46.63135+02	alanphiri@gmail.com	A2	2026-09-13	\N
39	ultra-CDL-2026-A-4 - UTH New Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-4 for UTH New Lab	1	4	2	2	1	16	4	Yes	NOT DETECTED	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.182223+02	wanangwa@gmail.com	2026-09-18 11:43:46.650062+02	alanphiri@gmail.com	A4	2026-09-13	\N
32	ultra-CDL-2026-A-2 - Ndola Teaching Hospital Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-2 for Ndola Teaching Hospital Lab	1	5	2	2	1	18	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	259	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.180223+02	wanangwa@gmail.com	2026-09-18 11:43:46.677734+02	grace.mulenga@ndola.health.zm	A2	2026-09-13	\N
33	ultra-CDL-2026-A-3 - Ndola Teaching Hospital Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-3 for Ndola Teaching Hospital Lab	1	5	2	2	1	18	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	259	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.181224+02	wanangwa@gmail.com	2026-09-18 11:43:46.686737+02	grace.mulenga@ndola.health.zm	A3	2026-09-13	\N
35	ultra-CDL-2026-A-5 - Ndola Teaching Hospital Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-5 for Ndola Teaching Hospital Lab	1	5	2	2	1	18	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	259	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.181224+02	wanangwa@gmail.com	2026-09-18 11:43:46.713694+02	grace.mulenga@ndola.health.zm	A1	2026-09-13	5007
40	ultra-CDL-2026-A-5 - UTH New Lab	<p>DTS Round Two 2026 panel sample ultra-CDL-2026-A-5 for UTH New Lab</p>	1	4	2	2	1	16	5	Yes	TRACE	NOT DETECTED	ERROR	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.183225+02	wanangwa@gmail.com	2026-09-24 14:24:57.166878+02	alanphiri@gmail.com	A1	2026-09-13	5007
51	ultra-CDL-2026-A-1 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample ultra-CDL-2026-A-1 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	11	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.186738+02	wanangwa@gmail.com	2026-09-18 11:43:46.454613+02	musachoolwe@gmail.com	A1	2026-09-13	\N
52	ultra-CDL-2026-A-2 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample ultra-CDL-2026-A-2 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	11	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.186738+02	wanangwa@gmail.com	2026-09-18 11:43:46.464617+02	musachoolwe@gmail.com	A2	2026-09-13	\N
53	ultra-CDL-2026-A-3 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample ultra-CDL-2026-A-3 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	11	3	Yes	LOW	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.187738+02	wanangwa@gmail.com	2026-09-18 11:43:46.474124+02	musachoolwe@gmail.com	A3	2026-09-13	\N
54	ultra-CDL-2026-A-4 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample ultra-CDL-2026-A-4 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	11	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.187738+02	wanangwa@gmail.com	2026-09-18 11:43:46.491657+02	musachoolwe@gmail.com	A4	2026-09-13	\N
55	ultra-CDL-2026-A-5 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample ultra-CDL-2026-A-5 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	11	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	255	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.187738+02	wanangwa@gmail.com	2026-09-18 11:43:46.508608+02	musachoolwe@gmail.com	A1	2026-09-13	5007
46	ultra-CDL-2026-A-1 - Levy Lusaka Laboratory	DTS Round Two 2026 panel sample ultra-CDL-2026-A-1 for Levy Lusaka Laboratory	1	2	2	2	1	13	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	256	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.185739+02	wanangwa@gmail.com	2026-09-18 11:43:46.519262+02	jane@gmail.com	A1	2026-09-13	\N
47	ultra-CDL-2026-A-2 - Levy Lusaka Laboratory	DTS Round Two 2026 panel sample ultra-CDL-2026-A-2 for Levy Lusaka Laboratory	1	2	2	2	1	13	2	Yes	HIGH	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	256	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.185739+02	wanangwa@gmail.com	2026-09-18 11:43:46.530779+02	jane@gmail.com	A2	2026-09-13	\N
48	ultra-CDL-2026-A-3 - Levy Lusaka Laboratory	DTS Round Two 2026 panel sample ultra-CDL-2026-A-3 for Levy Lusaka Laboratory	1	2	2	2	1	13	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	256	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.185739+02	wanangwa@gmail.com	2026-09-18 11:43:46.541463+02	jane@gmail.com	A3	2026-09-13	\N
49	ultra-CDL-2026-A-4 - Levy Lusaka Laboratory	DTS Round Two 2026 panel sample ultra-CDL-2026-A-4 for Levy Lusaka Laboratory	1	2	2	2	1	13	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	256	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.185739+02	wanangwa@gmail.com	2026-09-18 11:43:46.554045+02	jane@gmail.com	A4	2026-09-13	\N
50	ultra-CDL-2026-A-5 - Levy Lusaka Laboratory	DTS Round Two 2026 panel sample ultra-CDL-2026-A-5 for Levy Lusaka Laboratory	1	2	2	2	1	13	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	256	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.186738+02	wanangwa@gmail.com	2026-09-18 11:43:46.56355+02	jane@gmail.com	A1	2026-09-13	5007
42	ultra-CDL-2026-A-2 - Private Lab 1	DTS Round Two 2026 panel sample ultra-CDL-2026-A-2 for Private Lab 1	1	3	2	2	1	15	2	Yes	MEDIUM	NOT DETECTED	\N	22.8	16.2	17.1	16.9	18.5	17.3	257	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.183225+02	wanangwa@gmail.com	2026-09-18 11:43:46.585917+02	markdoe@gmail.com	A2	2026-09-13	\N
43	ultra-CDL-2026-A-3 - Private Lab 1	DTS Round Two 2026 panel sample ultra-CDL-2026-A-3 for Private Lab 1	1	3	2	2	1	15	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	257	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.183225+02	wanangwa@gmail.com	2026-09-18 11:43:46.595844+02	markdoe@gmail.com	A3	2026-09-13	\N
45	ultra-CDL-2026-A-5 - Private Lab 1	DTS Round Two 2026 panel sample ultra-CDL-2026-A-5 for Private Lab 1	1	3	2	2	1	15	5	No	\N	\N	ERROR	\N	\N	\N	\N	\N	\N	257	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.184732+02	wanangwa@gmail.com	2026-09-18 11:43:46.613327+02	markdoe@gmail.com	A1	2026-09-13	5007
38	ultra-CDL-2026-A-3 - UTH New Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-3 for UTH New Lab	1	4	2	2	1	16	3	Yes	MEDIUM	DETECTED	\N	23.1	21.4	22.1	21.9	24.5	22.1	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.182223+02	wanangwa@gmail.com	2026-09-18 11:43:46.640342+02	alanphiri@gmail.com	A3	2026-09-13	\N
31	ultra-CDL-2026-A-1 - Ndola Teaching Hospital Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-1 for Ndola Teaching Hospital Lab	1	5	2	2	1	18	1	Yes	NOT DETECTED	N/A	\N	23.4	0	0	0	0	0	259	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.179225+02	wanangwa@gmail.com	2026-09-18 11:43:46.667193+02	grace.mulenga@ndola.health.zm	A1	2026-09-13	\N
34	ultra-CDL-2026-A-4 - Ndola Teaching Hospital Lab	DTS Round Two 2026 panel sample ultra-CDL-2026-A-4 for Ndola Teaching Hospital Lab	1	5	2	2	1	18	4	Yes	TRACE	N/A	\N	24	27.8	28.4	28.1	29.9	28.6	259	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.181224+02	wanangwa@gmail.com	2026-09-18 11:43:46.701187+02	grace.mulenga@ndola.health.zm	A4	2026-09-13	\N
56	ultra-CDL-2026-A-1 - UTH New Lab	DTS Round One 2027 panel sample ultra-CDL-2026-A-1 for UTH New Lab	1	4	2	3	1	54	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:40.986548+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
57	ultra-CDL-2026-A-2 - UTH New Lab	DTS Round One 2027 panel sample ultra-CDL-2026-A-2 for UTH New Lab	1	4	2	3	1	54	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.015955+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
58	ultra-CDL-2026-A-3 - UTH New Lab	DTS Round One 2027 panel sample ultra-CDL-2026-A-3 for UTH New Lab	1	4	2	3	1	54	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.022028+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
59	ultra-CDL-2026-A-4 - UTH New Lab	DTS Round One 2027 panel sample ultra-CDL-2026-A-4 for UTH New Lab	1	4	2	3	1	54	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.028389+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
60	ultra-CDL-2026-A-5 - UTH New Lab	DTS Round One 2027 panel sample ultra-CDL-2026-A-5 for UTH New Lab	1	4	2	3	1	54	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.035067+02	nkoleevans@gmail.com	\N	\N	\N	\N	\N
\.


--
-- Data for Name: tb_xpert_xdr_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tb_xpert_xdr_results (id, name, description, scheme_id, lab_id, service_id, enrollment_id, pt_cycle_id, method_id, method_sample_id, date_tested, result_interpretable, tb_detection_result, inh_result, flq_result, amk_result, eth_result, uninterpretable_result, error_code, spc_ahpc, inha, katg, fabg1, gyra1, gyra2, gyra3, gyrb2, rrs, user_id, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by) FROM stdin;
8	xdr-CDL-2026-A-3 - UTH New Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-3 for UTH New Lab	1	4	2	7	1	2	8	2026-05-27	Yes	DETECTED	DETECTED	NOT DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	4	5	1	2026-09-18 11:43:45.538268+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.187343+02	wanangwa@gmail.com	2026-09-18 11:43:45.538268+02	quality@cdl.moh.gov.zm
11	xdr-CDL-2026-A-1 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample xdr-CDL-2026-A-1 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	2	6	2026-05-27	Yes	NOT DETECTED	N/A	N/A	N/A	N/A	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	4	5	1	2026-09-18 11:43:45.396136+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.18937+02	wanangwa@gmail.com	2026-09-18 11:43:45.396136+02	quality@cdl.moh.gov.zm
15	xdr-CDL-2026-A-5 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample xdr-CDL-2026-A-5 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	2	10	2026-05-27	No	\N	\N	\N	\N	\N	ERROR	5011	\N	\N	\N	\N	\N	\N	\N	\N	\N	255	4	5	1	2026-09-18 11:43:45.469684+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.190492+02	wanangwa@gmail.com	2026-09-18 11:43:45.469684+02	quality@cdl.moh.gov.zm
12	xdr-CDL-2026-A-2 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample xdr-CDL-2026-A-2 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	2	7	2026-05-27	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	4	5	1	2026-09-18 11:43:45.418157+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.189988+02	wanangwa@gmail.com	2026-09-18 11:43:45.419158+02	quality@cdl.moh.gov.zm
1	xdr-CDL-2026-A-1 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-1 for Kitwe Central Hospital Lab	1	6	2	10	1	2	6	2026-05-27	Yes	NOT DETECTED	N/A	N/A	N/A	N/A	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	260	4	5	1	2026-09-18 11:43:45.603024+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.178459+02	wanangwa@gmail.com	2026-09-18 11:43:45.603024+02	quality@cdl.moh.gov.zm
13	xdr-CDL-2026-A-3 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample xdr-CDL-2026-A-3 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	2	8	2026-05-27	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	4	5	1	2026-09-18 11:43:45.438162+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.190492+02	wanangwa@gmail.com	2026-09-18 11:43:45.438162+02	quality@cdl.moh.gov.zm
6	xdr-CDL-2026-A-1 - UTH New Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-1 for UTH New Lab	1	4	2	7	1	2	6	2026-05-27	Yes	NOT DETECTED	N/A	N/A	N/A	N/A	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	4	5	1	2026-09-18 11:43:45.485219+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.185965+02	wanangwa@gmail.com	2026-09-18 11:43:45.485219+02	quality@cdl.moh.gov.zm
14	xdr-CDL-2026-A-4 - Levy Mwanawasa University Teaching Hospital	DTS Round One 2026 panel sample xdr-CDL-2026-A-4 for Levy Mwanawasa University Teaching Hospital	1	1	2	2	1	2	9	2026-05-27	Yes	DETECTED	DETECTED	DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	4	5	1	2026-09-18 11:43:45.453676+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.190492+02	wanangwa@gmail.com	2026-09-18 11:43:45.453676+02	quality@cdl.moh.gov.zm
9	xdr-CDL-2026-A-4 - UTH New Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-4 for UTH New Lab	1	4	2	7	1	2	9	2026-05-27	Yes	DETECTED	NOT DETECTED	DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	4	5	1	2026-09-18 11:43:45.563902+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.188867+02	wanangwa@gmail.com	2026-09-18 11:43:45.564914+02	quality@cdl.moh.gov.zm
7	xdr-CDL-2026-A-2 - UTH New Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-2 for UTH New Lab	1	4	2	7	1	2	7	2026-05-27	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	4	5	1	2026-09-18 11:43:45.514266+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.187017+02	wanangwa@gmail.com	2026-09-18 11:43:45.515265+02	quality@cdl.moh.gov.zm
4	xdr-CDL-2026-A-4 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-4 for Kitwe Central Hospital Lab	1	6	2	10	1	2	9	2026-05-27	Yes	DETECTED	DETECTED	DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	260	4	5	1	2026-09-18 11:43:45.660639+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.183506+02	wanangwa@gmail.com	2026-09-18 11:43:45.660639+02	quality@cdl.moh.gov.zm
2	xdr-CDL-2026-A-2 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-2 for Kitwe Central Hospital Lab	1	6	2	10	1	2	7	2026-05-27	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	260	4	5	1	2026-09-18 11:43:45.622495+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.180939+02	wanangwa@gmail.com	2026-09-18 11:43:45.622495+02	quality@cdl.moh.gov.zm
10	xdr-CDL-2026-A-5 - UTH New Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-5 for UTH New Lab	1	4	2	7	1	2	10	2026-05-27	No	\N	\N	\N	\N	\N	ERROR	5011	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	4	5	1	2026-09-18 11:43:45.585472+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.188867+02	wanangwa@gmail.com	2026-09-18 11:43:45.585472+02	quality@cdl.moh.gov.zm
3	xdr-CDL-2026-A-3 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-3 for Kitwe Central Hospital Lab	1	6	2	10	1	2	8	2026-05-27	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	260	4	5	1	2026-09-18 11:43:45.642551+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.182999+02	wanangwa@gmail.com	2026-09-18 11:43:45.642551+02	quality@cdl.moh.gov.zm
5	xdr-CDL-2026-A-5 - Kitwe Central Hospital Lab	DTS Round One 2026 panel sample xdr-CDL-2026-A-5 for Kitwe Central Hospital Lab	1	6	2	10	1	2	10	2026-05-27	No	\N	\N	\N	\N	\N	ERROR	5011	\N	\N	\N	\N	\N	\N	\N	\N	\N	260	4	5	1	2026-09-18 11:43:45.687306+02	quality@cdl.moh.gov.zm	Graded against the expected panel result	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:44.184026+02	wanangwa@gmail.com	2026-09-18 11:43:45.687306+02	quality@cdl.moh.gov.zm
16	xdr-CDL-2026-A-1 - UTH New Lab	DTS Round Two 2026 panel sample xdr-CDL-2026-A-1 for UTH New Lab	1	4	2	17	2	2	6	2026-09-13	Yes	NOT DETECTED	N/A	N/A	N/A	N/A	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.188741+02	wanangwa@gmail.com	2026-09-18 11:43:46.806484+02	alanphiri@gmail.com
18	xdr-CDL-2026-A-3 - UTH New Lab	DTS Round Two 2026 panel sample xdr-CDL-2026-A-3 for UTH New Lab	1	4	2	17	2	2	8	2026-09-13	Yes	DETECTED	DETECTED	NOT DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.191738+02	wanangwa@gmail.com	2026-09-18 11:43:46.83148+02	alanphiri@gmail.com
21	xdr-CDL-2026-A-1 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample xdr-CDL-2026-A-1 for Levy Mwanawasa University Teaching Hospital	1	1	2	12	2	2	6	2026-09-13	Yes	NOT DETECTED	N/A	N/A	N/A	N/A	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.193754+02	wanangwa@gmail.com	2026-09-18 11:43:46.754315+02	musachoolwe@gmail.com
22	xdr-CDL-2026-A-2 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample xdr-CDL-2026-A-2 for Levy Mwanawasa University Teaching Hospital	1	1	2	12	2	2	7	2026-09-13	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.195752+02	wanangwa@gmail.com	2026-09-18 11:43:46.764493+02	musachoolwe@gmail.com
23	xdr-CDL-2026-A-3 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample xdr-CDL-2026-A-3 for Levy Mwanawasa University Teaching Hospital	1	1	2	12	2	2	8	2026-09-13	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.195752+02	wanangwa@gmail.com	2026-09-18 11:43:46.77449+02	musachoolwe@gmail.com
24	xdr-CDL-2026-A-4 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample xdr-CDL-2026-A-4 for Levy Mwanawasa University Teaching Hospital	1	1	2	12	2	2	9	2026-09-13	Yes	DETECTED	DETECTED	DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	255	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.19675+02	wanangwa@gmail.com	2026-09-18 11:43:46.783213+02	musachoolwe@gmail.com
25	xdr-CDL-2026-A-5 - Levy Mwanawasa University Teaching Hospital	DTS Round Two 2026 panel sample xdr-CDL-2026-A-5 for Levy Mwanawasa University Teaching Hospital	1	1	2	12	2	2	10	2026-09-13	No	\N	\N	\N	\N	\N	ERROR	5011	\N	\N	\N	\N	\N	\N	\N	\N	\N	255	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.19675+02	wanangwa@gmail.com	2026-09-18 11:43:46.796418+02	musachoolwe@gmail.com
17	xdr-CDL-2026-A-2 - UTH New Lab	DTS Round Two 2026 panel sample xdr-CDL-2026-A-2 for UTH New Lab	1	4	2	17	2	2	7	2026-09-13	Yes	DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	NOT DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.191738+02	wanangwa@gmail.com	2026-09-18 11:43:46.819481+02	alanphiri@gmail.com
19	xdr-CDL-2026-A-4 - UTH New Lab	DTS Round Two 2026 panel sample xdr-CDL-2026-A-4 for UTH New Lab	1	4	2	17	2	2	9	2026-09-13	Yes	DETECTED	NOT DETECTED	DETECTED	NOT DETECTED	DETECTED	\N	\N	22.1	22.3	24	23	23.2	21	22	22	21	258	2	2	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.192742+02	wanangwa@gmail.com	2026-09-18 11:43:46.844493+02	alanphiri@gmail.com
20	xdr-CDL-2026-A-5 - UTH New Lab	DTS Round Two 2026 panel sample xdr-CDL-2026-A-5 for UTH New Lab	1	4	2	17	2	2	10	2026-09-13	No	\N	\N	\N	\N	\N	ERROR	5011	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:46.192742+02	wanangwa@gmail.com	2026-09-18 11:43:46.859864+02	alanphiri@gmail.com
29	xdr-CDL-2026-A-1 - UTH New Lab	DTS Round One 2027 panel sample xdr-CDL-2026-A-1 for UTH New Lab	1	4	2	55	3	2	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.049264+02	nkoleevans@gmail.com	\N	\N
30	xdr-CDL-2026-A-2 - UTH New Lab	DTS Round One 2027 panel sample xdr-CDL-2026-A-2 for UTH New Lab	1	4	2	55	3	2	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.075249+02	nkoleevans@gmail.com	\N	\N
31	xdr-CDL-2026-A-3 - UTH New Lab	DTS Round One 2027 panel sample xdr-CDL-2026-A-3 for UTH New Lab	1	4	2	55	3	2	8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.082999+02	nkoleevans@gmail.com	\N	\N
32	xdr-CDL-2026-A-4 - UTH New Lab	DTS Round One 2027 panel sample xdr-CDL-2026-A-4 for UTH New Lab	1	4	2	55	3	2	9	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.089278+02	nkoleevans@gmail.com	\N	\N
33	xdr-CDL-2026-A-5 - UTH New Lab	DTS Round One 2027 panel sample xdr-CDL-2026-A-5 for UTH New Lab	1	4	2	55	3	2	10	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	258	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24 14:29:41.096342+02	nkoleevans@gmail.com	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, code, type, fname, lname, "position", email, mobile_code, mobile, address_physical, address_postal, role_id, password, status_id, stage_id, approval_levels, review1_at, review1_by, review1_comments, review2_at, review2_by, review2_comments, review3_at, review3_by, review3_comments, created_at, created_by, updated_at, updated_by, laboratory_id, province_id, district_id) FROM stdin;
267	\N	1	Rachel	Banda	Laboratory In-charge	rachel.banda@kitwemicro.health.zm	+260	+260979541479	Kitwe Teaching Hospital Microbiology, Zambia	Kitwe Teaching Hospital Microbiology, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$vhdCaE0JodR6z/kfQ+j9Pw$O3jXj+4lfm2QjVG1HBrsWYLh4f2/xWEGJV1ueq4vugA	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.576931+02	wanangwa@gmail.com	\N	\N	15	2	4
1	\N	1	Wanangwa	Doh	System Administrator	wanangwa@gmail.com	+260	+260978989259	\N	\N	1	$argon2id$v=19$m=65536,t=3,p=4$f89Zq9W617pX6l3LmfNe6w$GGc9KTusvPvuKW7BeGchEQj0Xrwkgq89AP85n2wT2Dw	4	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	2026-09-16 10:55:17.626497+02	wanangwa@gmail.com	\N	\N	\N
268	\N	1	Davies	Simukonda	Laboratory In-charge	davies.simukonda@lth.co.zm	+260	+260973116984	Lusaka Trust Hospital Laboratory, Zambia	Lusaka Trust Hospital Laboratory, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$uBei9D7nXEvpXauVcq41Jg$qU0GzZ8tw1QfmRdxFfDcIFqrmd9cOvAOp4+8HeE7MBk	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.717983+02	wanangwa@gmail.com	\N	\N	16	5	39
163	\N	1	John	Doe	System Administrator	nkoleevans@gmail.com	+260	+260978989259	\N	\N	1	$argon2id$v=19$m=65536,t=3,p=4$xvhfC2HM2bs3BoAQQggBoA$djDLvMJZA1FLr5zHWHORueCyMkMWk0ofF67UH+dbaAU	4	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	2026-09-18 11:43:41.34015+02	\N	\N	\N	\N
2	\N	1	Jane	Doe	Scheme Coordinator	nkoleevans@hotmail.com	+260	+260978989259	\N	\N	3	$argon2id$v=19$m=65536,t=3,p=4$GeMcY8zZW2sNAcBYKyUkZA$7zSph+l90e9EKGujuZABEWq3am0zUabMUy4Wt2DH2XQ	4	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	2026-09-18 11:43:41.430549+02	\N	\N	\N	\N
6	\N	\N	Mutende	Wina	Scheme Head	head@cdl.moh.gov.zm	+260	+260977004002	\N	\N	2	$argon2id$v=19$m=65536,t=3,p=4$vlfqPadUytnbe29t7T3HOA$Z2bdovxZI33JAo0AHV9lQXR1uLziV42MBksfzTW33IM	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.505726+02	demo-seed	2026-09-18 11:43:41.508375+02	\N	\N	5	39
7	\N	\N	Esther	Nyendwa	Quality Officer	quality@cdl.moh.gov.zm	+260	+260977004004	\N	\N	4	$argon2id$v=19$m=65536,t=3,p=4$9n4PgRCiVCoFQAgBgHAuhQ$NZau+6fesctf9BOjnM9CpJuRM/0IOFxQZd4snJJhmeM	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-14 20:23:25.593429+02	demo-seed	2026-09-18 11:43:41.585065+02	\N	\N	5	39
255	\N	1	Musa	Choolwe	Laboratory In-charge	musachoolwe@gmail.com	+260	+260979054634	Levy Mwanawasa University Teaching Hospital, Zambia	Levy Mwanawasa University Teaching Hospital, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$ovT+HwMgROg9R+i9N6Z0zg$COhRilDEDEzfgcMGtT1nBuAGg8BgiiG0uWb88BXbEPE	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:41.967528+02	wanangwa@gmail.com	\N	\N	1	5	39
256	\N	1	Jane	Banda	Laboratory In-charge	jane@gmail.com	+260	+260970703338	Levy Lusaka Laboratory, Zambia	Levy Lusaka Laboratory, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$ihECwPifE+L8H6M0xhjjPA$pmdRXEO0rLBf9V6jwR+pajeUxWSc/k/mQsHgBRtYT+I	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.159811+02	wanangwa@gmail.com	\N	\N	2	5	39
257	\N	1	Mark	Doe	Laboratory In-charge	markdoe@gmail.com	+260	+260975817667	Private Lab 1, Zambia	Private Lab 1, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$1For5VzLee99z1nLGaM0xg$akziS5poUj0D2wyajGrxy1p9wOJIXi5T9PlfgT3eFWM	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.312861+02	wanangwa@gmail.com	\N	\N	3	2	10
258	\N	1	Alan	Phiri	Laboratory In-charge	alanphiri@gmail.com	+260	+260977960898	UTH New Lab, Zambia	UTH New Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$vZfS+n/P+V9LSQlhTGkN4Q$6kc9TCpq2ZlwvetafzRI+FzyxUuqAwcl65C+ACyktJQ	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.444522+02	wanangwa@gmail.com	\N	\N	4	5	39
259	\N	1	Grace	Mulenga	Laboratory In-charge	grace.mulenga@ndola.health.zm	+260	+260973546432	Ndola Teaching Hospital Lab, Zambia	Ndola Teaching Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$HuMco9Ta+/+f817LmdPa+w$WfBbis2bdyyUGeBjfi5M7dDrXBA+S+tbmuv0tiKP+jw	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.562268+02	wanangwa@gmail.com	\N	\N	5	2	10
260	\N	1	Peter	Zulu	Laboratory In-charge	peter.zulu@kitwe.health.zm	+260	+260979319651	Kitwe Central Hospital Lab, Zambia	Kitwe Central Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$3FurVSoFgFCK0RojJAQgRA$yHTlEqK0OS0efbaH3p3wWs9WaOLIpLg7ejEmKGQrH2c	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.691284+02	wanangwa@gmail.com	\N	\N	6	2	4
261	\N	1	Chanda	Mwape	Laboratory In-charge	chanda.mwape@adch.health.zm	+260	+260972493914	Arthur Davison Childrens Hospital Lab, Zambia	Arthur Davison Childrens Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$qtWac8659/7/HyPE+P9fSw$+0KW+2dh3Dw+z+nTdYVK9ouP8TB/2VyGej0zqUV/0Zk	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.829538+02	wanangwa@gmail.com	\N	\N	9	2	10
262	\N	1	Foster	Tembo	Laboratory In-charge	foster.tembo@chipata.health.zm	+260	+260979709193	Chipata Central Hospital Lab, Zambia	Chipata Central Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$6X1vjZGSkhJiDIEQAuB8jw$8a9uy6cK9IFtD46Aqyjw51Kceg2cBBb8dgR6WKIsDr8	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:42.959985+02	wanangwa@gmail.com	\N	\N	10	3	15
263	\N	1	Idah	Nsofwa	Laboratory In-charge	idah.nsofwa@kabwe.health.zm	+260	+260970856398	Kabwe General Hospital Lab, Zambia	Kabwe General Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$aY3R2ptzjjFGCAGAkLKWUg$XuYmF+FNNiu1RVSXQ5emX3i+zhZosM9gPcK/uDHKDAU	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.076303+02	wanangwa@gmail.com	\N	\N	11	1	26
264	\N	1	Chola	Mumba	Laboratory In-charge	chola.mumba@mansa.health.zm	+260	+260977394710	Mansa General Hospital Lab, Zambia	Mansa General Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$ZEwpJWRs7f2/N8b4X0uJUQ$rqnF+FOpXRgR/smJlzcRiPn/wlq+4v2nPOBeRjUHzuE	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.198097+02	wanangwa@gmail.com	\N	\N	12	4	71
265	\N	1	Situmbeko	Imwiko	Laboratory In-charge	situmbeko.imwiko@mongu.health.zm	+260	+260971036651	Mongu Provincial Hospital Lab, Zambia	Mongu Provincial Hospital Lab, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$5xxDaK3V+l/r/d/7X6v1Hg$LDx3EFxjJhk7woMwEGu6nK7lLjMN0zrb3dkkGk3U5Es	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.314604+02	wanangwa@gmail.com	\N	\N	13	10	82
266	\N	1	Mwila	Chibesa	Laboratory In-charge	mwila.chibesa@ndolamicro.health.zm	+260	+260974323277	Ndola Teaching Hospital Microbiology, Zambia	Ndola Teaching Hospital Microbiology, Zambia	9	$argon2id$v=19$m=65536,t=3,p=4$n5PSGqM0Zsx57x1DCEGodQ$kt7rDSkQftvgOoLUWSX88oqtLemaRRrDYOTEHY+1vKI	4	5	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18 11:43:43.443551+02	wanangwa@gmail.com	\N	\N	14	2	10
174	\N	1	Kelvin	Doh	System Administrator	kelvin@gmail.com	+260	+260978989259	\N	\N	1	$argon2id$v=19$m=65536,t=3,p=4$f89Zq9W617pX6l3LmfNe6w$GGc9KTusvPvuKW7BeGchEQj0Xrwkgq89AP85n2wT2Dw	4	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	2026-09-14 23:43:59.693518+02	\N	\N	\N	\N
175	\N	1	Kelvin	Doh	System Administrator	beniah@gmail.com	+260	+260978989259	\N	\N	1	$argon2id$v=19$m=65536,t=3,p=4$f89Zq9W617pX6l3LmfNe6w$GGc9KTusvPvuKW7BeGchEQj0Xrwkgq89AP85n2wT2Dw	4	5	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-22 05:34:55.37776+02	nkoleevans@gmail.com	2026-09-14 23:43:59.693518+02	\N	\N	\N	\N
\.


--
-- Name: announcements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.announcements_id_seq', 18, true);


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.applications_id_seq', 30, true);


--
-- Name: attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.attachments_id_seq', 1, false);


--
-- Name: audits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audits_id_seq', 2003, true);


--
-- Name: bacteriology_ast_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bacteriology_ast_results_id_seq', 43, true);


--
-- Name: bacteriology_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bacteriology_results_id_seq', 43, true);


--
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.districts_id_seq', 104, true);


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enrollments_id_seq', 55, true);


--
-- Name: hiv_eid_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hiv_eid_results_id_seq', 59, true);


--
-- Name: hiv_vl_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hiv_vl_results_id_seq', 53, true);


--
-- Name: lab_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.lab_types_id_seq', 4, true);


--
-- Name: laboratorys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.laboratorys_id_seq', 19, true);


--
-- Name: list_stages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.list_stages_id_seq', 1, false);


--
-- Name: list_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.list_statuses_id_seq', 1, false);


--
-- Name: meters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meters_id_seq', 1, false);


--
-- Name: method_sample_expected_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.method_sample_expected_values_id_seq', 81, true);


--
-- Name: method_samples_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.method_samples_id_seq', 54, true);


--
-- Name: methods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.methods_id_seq', 11, true);


--
-- Name: providers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.providers_id_seq', 3, true);


--
-- Name: provinces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.provinces_id_seq', 10, true);


--
-- Name: pt_cycle_samples_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_cycle_samples_id_seq', 1, false);


--
-- Name: pt_cycle_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_cycle_statuses_id_seq', 5, true);


--
-- Name: pt_cycles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_cycles_id_seq', 11, true);


--
-- Name: pt_enrollment_performance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_enrollment_performance_id_seq', 27, true);


--
-- Name: pt_result_evaluations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_result_evaluations_id_seq', 285, true);


--
-- Name: pt_sample_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pt_sample_statistics_id_seq', 70, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 10, true);


--
-- Name: schemes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schemes_id_seq', 4, true);


--
-- Name: services_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.services_id_seq', 5, true);


--
-- Name: tb_xpert_ultra_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_xpert_ultra_results_id_seq', 60, true);


--
-- Name: tb_xpert_xdr_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tb_xpert_xdr_results_id_seq', 33, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 268, true);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: bacteriology_ast_results bacteriology_ast_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_ast_results
    ADD CONSTRAINT bacteriology_ast_results_pkey PRIMARY KEY (id);


--
-- Name: bacteriology_results bacteriology_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_pkey PRIMARY KEY (id);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: hiv_eid_results hiv_eid_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_pkey PRIMARY KEY (id);


--
-- Name: hiv_vl_results hiv_vl_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_pkey PRIMARY KEY (id);


--
-- Name: lab_types lab_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_pkey PRIMARY KEY (id);


--
-- Name: laboratorys laboratorys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_pkey PRIMARY KEY (id);


--
-- Name: list_stages list_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_stages
    ADD CONSTRAINT list_stages_pkey PRIMARY KEY (id);


--
-- Name: list_statuses list_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.list_statuses
    ADD CONSTRAINT list_statuses_pkey PRIMARY KEY (id);


--
-- Name: meters meters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_pkey PRIMARY KEY (id);


--
-- Name: method_sample_expected_values method_sample_expected_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_sample_expected_values
    ADD CONSTRAINT method_sample_expected_values_pkey PRIMARY KEY (id);


--
-- Name: method_samples method_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_pkey PRIMARY KEY (id);


--
-- Name: methods methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- Name: pt_cycle_samples pt_cycle_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_pkey PRIMARY KEY (id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_pkey PRIMARY KEY (id);


--
-- Name: pt_cycles pt_cycles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_pkey PRIMARY KEY (id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_pkey PRIMARY KEY (id);


--
-- Name: pt_result_evaluations pt_result_evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_pkey PRIMARY KEY (id);


--
-- Name: pt_sample_statistics pt_sample_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT pt_sample_statistics_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schemes schemes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_pkey PRIMARY KEY (id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_pkey PRIMARY KEY (id);


--
-- Name: applications uq_applications_lab_method; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT uq_applications_lab_method UNIQUE (lab_id, method_id);


--
-- Name: bacteriology_ast_results uq_bacteriology_ast_results_result_method_antibiotic; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_ast_results
    ADD CONSTRAINT uq_bacteriology_ast_results_result_method_antibiotic UNIQUE (bacteriology_result_id, ast_method, antibiotic) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bacteriology_ast_results uq_bacteriology_ast_results_result_method_row; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_ast_results
    ADD CONSTRAINT uq_bacteriology_ast_results_result_method_row UNIQUE (bacteriology_result_id, ast_method, row_no) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bacteriology_results uq_bacteriology_results_cycle_lab_sample; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT uq_bacteriology_results_cycle_lab_sample UNIQUE (pt_cycle_id, lab_id, method_sample_id);


--
-- Name: enrollments uq_enrollments_cycle_lab_method; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT uq_enrollments_cycle_lab_method UNIQUE (pt_cycle_id, lab_id, method_id);


--
-- Name: hiv_eid_results uq_hiv_eid_results_cycle_lab_sample; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT uq_hiv_eid_results_cycle_lab_sample UNIQUE (pt_cycle_id, lab_id, method_sample_id);


--
-- Name: hiv_vl_results uq_hiv_vl_results_cycle_lab_sample; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT uq_hiv_vl_results_cycle_lab_sample UNIQUE (pt_cycle_id, lab_id, method_sample_id);


--
-- Name: lab_types uq_lab_types_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT uq_lab_types_name UNIQUE (name);


--
-- Name: laboratorys uq_laboratorys_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT uq_laboratorys_code UNIQUE (code);


--
-- Name: laboratorys uq_laboratorys_email_address; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT uq_laboratorys_email_address UNIQUE (email_address);


--
-- Name: method_sample_expected_values uq_method_sample_expected_values_sample_attribute; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_sample_expected_values
    ADD CONSTRAINT uq_method_sample_expected_values_sample_attribute UNIQUE (method_sample_id, attribute);


--
-- Name: method_samples uq_method_samples_method_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT uq_method_samples_method_name UNIQUE (method_id, name);


--
-- Name: methods uq_methods_service_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT uq_methods_service_name UNIQUE (service_id, name);


--
-- Name: providers uq_providers_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT uq_providers_name UNIQUE (name);


--
-- Name: pt_cycle_statuses uq_pt_cycle_statuses_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT uq_pt_cycle_statuses_name UNIQUE (name);


--
-- Name: pt_cycles uq_pt_cycles_scheme_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT uq_pt_cycles_scheme_code UNIQUE (scheme_id, code);


--
-- Name: pt_enrollment_performance uq_pt_enrollment_performance_enrollment; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT uq_pt_enrollment_performance_enrollment UNIQUE (enrollment_id);


--
-- Name: pt_result_evaluations uq_pt_result_evaluations_result_attribute; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT uq_pt_result_evaluations_result_attribute UNIQUE (result_form, result_id, attribute);


--
-- Name: pt_sample_statistics uq_pt_sample_statistics_cycle_sample_attribute; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT uq_pt_sample_statistics_cycle_sample_attribute UNIQUE (pt_cycle_id, method_sample_id, attribute);


--
-- Name: roles uq_roles_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT uq_roles_name UNIQUE (name);


--
-- Name: schemes uq_schemes_provider_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT uq_schemes_provider_name UNIQUE (provider_id, name);


--
-- Name: services uq_services_scheme_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT uq_services_scheme_name UNIQUE (scheme_id, name);


--
-- Name: tb_xpert_ultra_results uq_tb_xpert_ultra_results_cycle_lab_sample; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT uq_tb_xpert_ultra_results_cycle_lab_sample UNIQUE (pt_cycle_id, lab_id, method_sample_id);


--
-- Name: tb_xpert_xdr_results uq_tb_xpert_xdr_results_cycle_lab_sample; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT uq_tb_xpert_xdr_results_cycle_lab_sample UNIQUE (pt_cycle_id, lab_id, method_sample_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_announcements_audience; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_announcements_audience ON public.announcements USING btree (audience, scheme_id);


--
-- Name: ix_announcements_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_announcements_id ON public.announcements USING btree (id);


--
-- Name: ix_announcements_window; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_announcements_window ON public.announcements USING btree (status_id, publish_from, publish_until);


--
-- Name: ix_applications_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_applications_id ON public.applications USING btree (id);


--
-- Name: ix_attachments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_attachments_id ON public.attachments USING btree (id);


--
-- Name: ix_audits_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audits_id ON public.audits USING btree (id);


--
-- Name: ix_bacteriology_ast_results_bacteriology_result_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bacteriology_ast_results_bacteriology_result_id ON public.bacteriology_ast_results USING btree (bacteriology_result_id);


--
-- Name: ix_bacteriology_ast_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bacteriology_ast_results_id ON public.bacteriology_ast_results USING btree (id);


--
-- Name: ix_bacteriology_ast_results_result; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bacteriology_ast_results_result ON public.bacteriology_ast_results USING btree (bacteriology_result_id);


--
-- Name: ix_bacteriology_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bacteriology_results_id ON public.bacteriology_results USING btree (id);


--
-- Name: ix_districts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_districts_id ON public.districts USING btree (id);


--
-- Name: ix_enrollments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_enrollments_id ON public.enrollments USING btree (id);


--
-- Name: ix_hiv_eid_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_hiv_eid_results_id ON public.hiv_eid_results USING btree (id);


--
-- Name: ix_hiv_vl_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_hiv_vl_results_id ON public.hiv_vl_results USING btree (id);


--
-- Name: ix_lab_types_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_lab_types_id ON public.lab_types USING btree (id);


--
-- Name: ix_laboratorys_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_laboratorys_id ON public.laboratorys USING btree (id);


--
-- Name: ix_list_stages_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_list_stages_id ON public.list_stages USING btree (id);


--
-- Name: ix_list_statuses_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_list_statuses_id ON public.list_statuses USING btree (id);


--
-- Name: ix_meters_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meters_id ON public.meters USING btree (id);


--
-- Name: ix_method_samples_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_method_samples_id ON public.method_samples USING btree (id);


--
-- Name: ix_methods_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_methods_id ON public.methods USING btree (id);


--
-- Name: ix_providers_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_providers_id ON public.providers USING btree (id);


--
-- Name: ix_provinces_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_provinces_id ON public.provinces USING btree (id);


--
-- Name: ix_pt_cycle_samples_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_cycle_samples_id ON public.pt_cycle_samples USING btree (id);


--
-- Name: ix_pt_cycle_statuses_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_cycle_statuses_id ON public.pt_cycle_statuses USING btree (id);


--
-- Name: ix_pt_cycles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_cycles_id ON public.pt_cycles USING btree (id);


--
-- Name: ix_pt_enrollment_performance_cycle_lab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_enrollment_performance_cycle_lab ON public.pt_enrollment_performance USING btree (pt_cycle_id, lab_id);


--
-- Name: ix_pt_enrollment_performance_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_enrollment_performance_id ON public.pt_enrollment_performance USING btree (id);


--
-- Name: ix_pt_result_evaluations_cycle_lab; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_result_evaluations_cycle_lab ON public.pt_result_evaluations USING btree (pt_cycle_id, lab_id);


--
-- Name: ix_pt_result_evaluations_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_result_evaluations_id ON public.pt_result_evaluations USING btree (id);


--
-- Name: ix_pt_sample_statistics_cycle; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_sample_statistics_cycle ON public.pt_sample_statistics USING btree (pt_cycle_id);


--
-- Name: ix_pt_sample_statistics_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_pt_sample_statistics_id ON public.pt_sample_statistics USING btree (id);


--
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- Name: ix_schemes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_schemes_id ON public.schemes USING btree (id);


--
-- Name: ix_services_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_services_id ON public.services USING btree (id);


--
-- Name: ix_tb_xpert_ultra_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tb_xpert_ultra_results_id ON public.tb_xpert_ultra_results USING btree (id);


--
-- Name: ix_tb_xpert_xdr_results_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_tb_xpert_xdr_results_id ON public.tb_xpert_xdr_results USING btree (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: announcements announcements_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: announcements announcements_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: announcements announcements_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: announcements announcements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: applications applications_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: applications applications_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: applications applications_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: applications applications_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: applications applications_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: applications applications_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: applications applications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bacteriology_ast_results bacteriology_ast_results_bacteriology_result_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_ast_results
    ADD CONSTRAINT bacteriology_ast_results_bacteriology_result_id_fkey FOREIGN KEY (bacteriology_result_id) REFERENCES public.bacteriology_results(id) ON DELETE CASCADE;


--
-- Name: bacteriology_results bacteriology_results_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: bacteriology_results bacteriology_results_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: bacteriology_results bacteriology_results_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: bacteriology_results bacteriology_results_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: bacteriology_results bacteriology_results_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: bacteriology_results bacteriology_results_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: bacteriology_results bacteriology_results_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: bacteriology_results bacteriology_results_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: bacteriology_results bacteriology_results_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: bacteriology_results bacteriology_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bacteriology_results
    ADD CONSTRAINT bacteriology_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: districts districts_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- Name: districts districts_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: districts districts_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: districts districts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: enrollments enrollments_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: enrollments enrollments_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: enrollments enrollments_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: enrollments enrollments_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: enrollments enrollments_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: enrollments enrollments_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: enrollments enrollments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: hiv_eid_results hiv_eid_results_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: hiv_eid_results hiv_eid_results_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: hiv_eid_results hiv_eid_results_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: hiv_eid_results hiv_eid_results_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: hiv_eid_results hiv_eid_results_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: hiv_eid_results hiv_eid_results_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: hiv_eid_results hiv_eid_results_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: hiv_eid_results hiv_eid_results_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: hiv_eid_results hiv_eid_results_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: hiv_eid_results hiv_eid_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_eid_results
    ADD CONSTRAINT hiv_eid_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: hiv_vl_results hiv_vl_results_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: hiv_vl_results hiv_vl_results_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: hiv_vl_results hiv_vl_results_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: hiv_vl_results hiv_vl_results_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: hiv_vl_results hiv_vl_results_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: hiv_vl_results hiv_vl_results_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: hiv_vl_results hiv_vl_results_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: hiv_vl_results hiv_vl_results_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: hiv_vl_results hiv_vl_results_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: hiv_vl_results hiv_vl_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hiv_vl_results
    ADD CONSTRAINT hiv_vl_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: lab_types lab_types_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: lab_types lab_types_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: lab_types lab_types_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lab_types
    ADD CONSTRAINT lab_types_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: laboratorys laboratorys_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id);


--
-- Name: laboratorys laboratorys_lab_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_lab_type_id_fkey FOREIGN KEY (lab_type_id) REFERENCES public.lab_types(id);


--
-- Name: laboratorys laboratorys_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- Name: laboratorys laboratorys_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: laboratorys laboratorys_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: laboratorys laboratorys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laboratorys
    ADD CONSTRAINT laboratorys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meters meters_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: meters meters_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: meters meters_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meters
    ADD CONSTRAINT meters_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: method_sample_expected_values method_sample_expected_values_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_sample_expected_values
    ADD CONSTRAINT method_sample_expected_values_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id) ON DELETE CASCADE;


--
-- Name: method_samples method_samples_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: method_samples method_samples_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: method_samples method_samples_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: method_samples method_samples_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: method_samples method_samples_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: method_samples method_samples_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.method_samples
    ADD CONSTRAINT method_samples_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: methods methods_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: methods methods_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: methods methods_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: methods methods_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: methods methods_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.methods
    ADD CONSTRAINT methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: providers providers_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: providers providers_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: providers providers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: provinces provinces_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: provinces provinces_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: provinces provinces_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_cycle_samples pt_cycle_samples_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: pt_cycle_samples pt_cycle_samples_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: pt_cycle_samples pt_cycle_samples_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_samples
    ADD CONSTRAINT pt_cycle_samples_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: pt_cycle_statuses pt_cycle_statuses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycle_statuses
    ADD CONSTRAINT pt_cycle_statuses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_cycles pt_cycles_pt_cyle_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_pt_cyle_status_id_fkey FOREIGN KEY (pt_cyle_status_id) REFERENCES public.pt_cycle_statuses(id);


--
-- Name: pt_cycles pt_cycles_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: pt_cycles pt_cycles_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: pt_cycles pt_cycles_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: pt_cycles pt_cycles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_cycles
    ADD CONSTRAINT pt_cycles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: pt_enrollment_performance pt_enrollment_performance_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_enrollment_performance
    ADD CONSTRAINT pt_enrollment_performance_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: pt_result_evaluations pt_result_evaluations_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_result_evaluations
    ADD CONSTRAINT pt_result_evaluations_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: pt_sample_statistics pt_sample_statistics_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT pt_sample_statistics_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: pt_sample_statistics pt_sample_statistics_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT pt_sample_statistics_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: pt_sample_statistics pt_sample_statistics_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT pt_sample_statistics_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: pt_sample_statistics pt_sample_statistics_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT pt_sample_statistics_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: pt_sample_statistics pt_sample_statistics_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pt_sample_statistics
    ADD CONSTRAINT pt_sample_statistics_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: roles roles_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: roles roles_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: roles roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: schemes schemes_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.providers(id);


--
-- Name: schemes schemes_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: schemes schemes_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: schemes schemes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schemes
    ADD CONSTRAINT schemes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: services services_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: services services_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: services services_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: tb_xpert_ultra_results tb_xpert_ultra_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_ultra_results
    ADD CONSTRAINT tb_xpert_ultra_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_lab_id_fkey FOREIGN KEY (lab_id) REFERENCES public.laboratorys(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_method_id_fkey FOREIGN KEY (method_id) REFERENCES public.methods(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_method_sample_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_method_sample_id_fkey FOREIGN KEY (method_sample_id) REFERENCES public.method_samples(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_pt_cycle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_pt_cycle_id_fkey FOREIGN KEY (pt_cycle_id) REFERENCES public.pt_cycles(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_scheme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_scheme_id_fkey FOREIGN KEY (scheme_id) REFERENCES public.schemes(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- Name: tb_xpert_xdr_results tb_xpert_xdr_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tb_xpert_xdr_results
    ADD CONSTRAINT tb_xpert_xdr_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.list_stages(id);


--
-- Name: users users_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_status_id_fkey FOREIGN KEY (status_id) REFERENCES public.list_statuses(id);


--
-- PostgreSQL database dump complete
--

