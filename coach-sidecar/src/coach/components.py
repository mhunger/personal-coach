"""The component registry — the vocabulary the coach publishes in.

v1 ships four types: TextBlock, SuggestionCard, TrainingSessionCard, RecipeCard.
Pydantic validates each component on the way out of the `render` tool. Invalid
components are rejected so the agent has to retry with a valid shape rather
than producing broken UI.

Adding a component = add a Pydantic model here and a matching widget in
frontend/lib/features/coach/presentation/components/.
"""

from __future__ import annotations

from typing import Annotated, Any, Literal

from pydantic import BaseModel, Field, ValidationError


class TextBlock(BaseModel):
    type: Literal["TextBlock"] = "TextBlock"
    content: str


class SuggestionCard(BaseModel):
    type: Literal["SuggestionCard"] = "SuggestionCard"
    tag: str = Field(..., description='Short uppercase tag, e.g. "FOR TODAY"')
    heading: str
    body: str
    action_label: str | None = Field(None, alias="actionLabel")
    action_ref: str | None = Field(None, alias="actionRef")

    class Config:
        populate_by_name = True


class Exercise(BaseModel):
    name: str
    sets: int | None = None
    reps: str | None = None  # "8" or "8-10" or "AMRAP"
    weight: str | None = None  # "80kg" or "bodyweight"
    notes: str | None = None


class TrainingSessionCard(BaseModel):
    type: Literal["TrainingSessionCard"] = "TrainingSessionCard"
    day_of_week: str = Field(..., alias="dayOfWeek")
    planned_start: str | None = Field(None, alias="plannedStart")  # "07:30"
    duration_minutes: int = Field(..., alias="durationMinutes")
    focus: str
    exercises: list[Exercise] = Field(default_factory=list)
    notes: str | None = None

    class Config:
        populate_by_name = True


class Ingredient(BaseModel):
    quantity: str
    item: str


class RecipeCard(BaseModel):
    type: Literal["RecipeCard"] = "RecipeCard"
    title: str
    image_url: str | None = Field(None, alias="imageUrl")
    servings: int
    prep_minutes: int = Field(..., alias="prepMinutes")
    cook_minutes: int = Field(..., alias="cookMinutes")
    ingredients: list[Ingredient]
    method: list[str]
    notes: str | None = None

    class Config:
        populate_by_name = True


Component = Annotated[
    TextBlock | SuggestionCard | TrainingSessionCard | RecipeCard,
    Field(discriminator="type"),
]


def validate_components(raw: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Validate a list of raw component dicts from the `render` tool.

    Returns the list as dicts (JSON-ready, camelCase) so the backend and
    Flutter receive consistent shapes. Raises `ComponentValidationError`
    when any component is invalid.
    """
    valid: list[dict[str, Any]] = []
    errors: list[str] = []
    for idx, r in enumerate(raw or []):
        kind = (r or {}).get("type")
        model = _REGISTRY.get(kind)
        if model is None:
            errors.append(f"[{idx}] unknown component type {kind!r}")
            continue
        try:
            valid.append(model.model_validate(r).model_dump(by_alias=True, exclude_none=True))
        except ValidationError as exc:
            errors.append(f"[{idx}] {kind}: {exc.errors()}")
    if errors:
        raise ComponentValidationError("; ".join(errors))
    return valid


class ComponentValidationError(ValueError):
    """Raised when the agent publishes a component that doesn't match a registry type."""


_REGISTRY: dict[str, type[BaseModel]] = {
    "TextBlock": TextBlock,
    "SuggestionCard": SuggestionCard,
    "TrainingSessionCard": TrainingSessionCard,
    "RecipeCard": RecipeCard,
}


REGISTRY_DESCRIPTION_FOR_PROMPT = """\
Available component types (always set `type` to one of these exact strings):

  TextBlock             { "type":"TextBlock", "content": string }
  SuggestionCard        { "type":"SuggestionCard", "tag": UPPER_SHORT,
                           "heading": string, "body": string,
                           "actionLabel"?: string, "actionRef"?: string }
  TrainingSessionCard   { "type":"TrainingSessionCard", "dayOfWeek": "MONDAY"|...,
                           "plannedStart"?: "HH:MM", "durationMinutes": int,
                           "focus": string,
                           "exercises": [{ "name": string, "sets"?: int,
                                           "reps"?: string, "weight"?: string,
                                           "notes"?: string }],
                           "notes"?: string }
  RecipeCard            { "type":"RecipeCard", "title": string, "imageUrl"?: string,
                           "servings": int, "prepMinutes": int, "cookMinutes": int,
                           "ingredients": [{ "quantity": string, "item": string }],
                           "method": [string], "notes"?: string }
"""
