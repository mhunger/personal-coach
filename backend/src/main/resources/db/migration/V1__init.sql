-- V1: initial schema for personal-coach v1.
-- Profile is single-row; schedule is keyed by ISO week; training plan + sessions;
-- coach conversations + messages persist the component stream as JSON.

CREATE TABLE user_profile (
    id                      BIGINT        NOT NULL AUTO_INCREMENT,
    date_of_birth           DATE          NULL,
    height_cm               INT           NULL,
    weight_kg               DECIMAL(5, 2) NULL,
    body_fat_pct            DECIMAL(4, 1) NULL,
    primary_goal            VARCHAR(255)  NULL,
    target_weight_kg        DECIMAL(5, 2) NULL,
    injuries                TEXT          NULL,
    dietary_restrictions    TEXT          NULL,
    work_hours_description  TEXT          NULL,
    gym_access              VARCHAR(32)   NOT NULL DEFAULT 'HOME',
    equipment               TEXT          NULL,
    training_days_per_week  INT           NULL,
    session_minutes_target  INT           NULL,
    created_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE weekly_schedule (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    iso_week     VARCHAR(10)  NOT NULL,
    notes        TEXT         NULL,
    busy_blocks  JSON         NULL,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_weekly_schedule_iso_week (iso_week)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE training_plan (
    id            BIGINT      NOT NULL AUTO_INCREMENT,
    iso_week      VARCHAR(10) NOT NULL,
    generated_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    rationale     TEXT        NULL,
    PRIMARY KEY (id),
    KEY idx_training_plan_iso_week (iso_week)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE training_session (
    id                BIGINT       NOT NULL AUTO_INCREMENT,
    plan_id           BIGINT       NOT NULL,
    day_of_week       VARCHAR(10)  NOT NULL,
    planned_start     TIME         NULL,
    duration_minutes  INT          NOT NULL,
    focus             VARCHAR(255) NOT NULL,
    exercises         JSON         NULL,
    PRIMARY KEY (id),
    KEY idx_training_session_plan (plan_id),
    CONSTRAINT fk_training_session_plan
        FOREIGN KEY (plan_id) REFERENCES training_plan (id)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE coach_conversation (
    id               BIGINT    NOT NULL AUTO_INCREMENT,
    started_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_message_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE coach_message (
    id               BIGINT      NOT NULL AUTO_INCREMENT,
    conversation_id  BIGINT      NOT NULL,
    role             VARCHAR(10) NOT NULL,
    components       JSON        NOT NULL,
    created_at       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_coach_message_conversation (conversation_id),
    CONSTRAINT fk_coach_message_conversation
        FOREIGN KEY (conversation_id) REFERENCES coach_conversation (id)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;
