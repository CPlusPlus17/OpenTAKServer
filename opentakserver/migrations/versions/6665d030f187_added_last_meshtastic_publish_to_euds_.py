"""Added last_meshtastic_publish to EUDs table

Revision ID: 6665d030f187
Revises: 1041fae84708
Create Date: 2025-01-30 14:07:58.600407

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6665d030f187'
down_revision = '1041fae84708'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('euds', schema=None) as batch_op:
        batch_op.add_column(sa.Column('last_meshtastic_publish', sa.DateTime(), nullable=True))

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('euds', schema=None) as batch_op:
        batch_op.drop_column('last_meshtastic_publish')


    # ### end Alembic commands ###
